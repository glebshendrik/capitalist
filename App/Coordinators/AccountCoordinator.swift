//
//  AccountCoordinator.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import StoreKit
import ApphudSDK
import SwiftyBeaver
import SaltEdge
import SwifterSwift

enum AuthProviderError : Error {
    case emailHasAlreadyUsed
    case userIdIsNotSpecified
    case authenticationIsCancelled
    case canNotGetProviderSessionData
    case canNotGetProviderUserData
}

class AccountCoordinator : AccountCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let authenticationService: AuthenticationServiceProtocol
    private let usersService: UsersServiceProtocol
    private let router: ApplicationRouterProtocol
    private let notificationsCoordinator: NotificationsCoordinatorProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    private let saltEdgeManager: SaltEdgeManagerProtocol
    
    var currentSession: Session? {
        return userSessionManager.currentSession
    }
    
    var hasPremiumSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return !([activePremiumMonthly,
                  activePremiumYearly,
                  activePremiumSixMonths,
                  activePremiumUnlimitedCIS,
                  activePremiumUnlimitedNonCIS]
                    .compactMap { $0 }
                    .isEmpty)
        #endif
    }
    
    var hasPremiumUnlimitedSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return !([activePremiumUnlimitedCIS,
                  activePremiumUnlimitedNonCIS]
                    .compactMap { $0 }
                    .isEmpty)
        #endif
    }
    
    var hasPlatinumSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        let hasPlatinum = !([activePlatinumMonthly,
                             activePlatinumYearly]
                                .compactMap { $0 }
                                .isEmpty)
        
        let hasPlatinumPure = !([activePlatinumPureMonthly,
                                 activePlatinumPureYearly]
                                    .compactMap { $0 }
                                    .isEmpty)
        
        
        
        return hasPlatinum || (hasPremiumUnlimitedSubscription && hasPlatinumPure)
        #endif
    }
    
    var currentUserHasActiveSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return Apphud.hasActiveSubscription()
        #endif
    }
    
    var subscription: ApphudSubscription? {
        #if targetEnvironment(simulator)
        return nil
        #else
        if hasPlatinumSubscription {
            return
                activePlatinumMonthly ??
                activePlatinumYearly ??
                activePlatinumPureMonthly ??
                activePlatinumPureYearly
        }
        
        if hasPremiumUnlimitedSubscription {
            return
                activePremiumUnlimitedCIS ??
                activePremiumUnlimitedNonCIS
        }
        
        return
            activePremiumMonthly ??
            activePremiumSixMonths ??
            activePremiumYearly
        #endif
    }
    
    var subscriptionProducts: [SKProduct] {
        return Apphud.products() ?? []
    }
    
    var premiumFeaturesAvailable: Bool {
        return hasPremiumSubscription || hasPlatinumSubscription
    }
    
    var platinumFeaturesAvailable: Bool {
        return hasPlatinumSubscription        
    }
    
    var hasActiveSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return subscription != nil
        #endif
    }
    
    init(userSessionManager: UserSessionManagerProtocol,
         authenticationService: AuthenticationServiceProtocol,
         usersService: UsersServiceProtocol,
         router: ApplicationRouterProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol,
         analyticsManager: AnalyticsManagerProtocol,
         saltEdgeManager: SaltEdgeManagerProtocol) {
        
        self.userSessionManager = userSessionManager
        self.authenticationService = authenticationService
        self.usersService = usersService
        self.router = router
        self.notificationsCoordinator = notificationsCoordinator
        self.analyticsManager = analyticsManager
        self.saltEdgeManager = saltEdgeManager
    }
    
    private func getActiveSubscription(_ subscription: SubscriptionProduct) -> ApphudSubscription? {
        return Apphud.subscriptions()?.first(where: { $0.isActive() && $0.productId == subscription.id })
    }
    
    func joinAsGuest() -> Promise<Session> {
        return authenticate(with: SessionCreationForm(email: nil, password: nil, skipValidation: true))
    }
    
    func authenticate(with form: SessionCreationForm) -> Promise<Session> {
        return  firstly {
            authenticationService.authenticate(form: form)
        }.get { session in
            self.userSessionManager.save(session: session)
        }.then { session in
            self.updateUserSubscription().map { session }
        }.get { session in
            self.router.route()
        }
    }
    
    func authenticate(with json: String) -> Promise<Session> {        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        guard  let data = json.data(using: .utf8),
               let objectDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let object = try? decoder.decode(Session.self, withJSONObject: objectDictionary) else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return  firstly {
            Promise.value(object)
        }.get { session in
            self.userSessionManager.save(session: session)
        }.get { session in
            self.router.route()
        }
    }
    
    func createAndAuthenticateUser(with userForm: UserCreationForm) -> Promise<Session> {
        return  firstly {
            usersService.createUser(with: userForm)
        }.get { user in
            self.analyticsManager.trackSignUp(user: user)
        }.then { user in
            self.authenticate(with: SessionCreationForm(email: userForm.email, password: userForm.password))
        }
    }
    
    func updateUser(with userForm: UserUpdatingForm) -> Promise<Void> {
        return usersService.updateUser(with: userForm)
    }
    
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        let form = ChangePasswordForm(userId: currentUserId,
                                      oldPassword: changePasswordForm.oldPassword,
                                      newPassword: changePasswordForm.newPassword,
                                      newPasswordConfirmation: changePasswordForm.newPasswordConfirmation)
        return usersService.changePassword(with: form)
    }
    
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void> {
        return  firstly {
            usersService.resetPassword(with: resetPasswordForm)
        }.then { _ in
            self.authenticate(with: SessionCreationForm(email: resetPasswordForm.email,
                                                        password: resetPasswordForm.password))
        }.asVoid()
    }
    
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void> {
        return usersService.createPasswordResetCode(with: passwordResetCodeForm)
    }
    
    func loadCurrentUser() -> Promise<User> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return  firstly {
            usersService.loadUser(with: currentUserId)
        }.then { user -> Promise<User> in
            if user.hasActiveSubscription != self.currentUserHasActiveSubscription {
                return self.updateUserSubscription().map { user }
            }
            return Promise.value(user)
        }.get { user in            
            self.analyticsManager.set(userId: String(user.id))
            SwiftyBeaver.cloud?.analyticsUserName = "user_id:\(user.id)"
            Apphud.updateUserID(String(user.id))
            if let customerSecret = user.saltEdgeCustomerSecret {
                self.saltEdgeManager.set(customerSecret: customerSecret)
            }
        }
    }
    
    func loadCurrentUserBudget() -> Promise<Budget> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return usersService.loadUserBudget(with: currentUserId)
    }
    
    func onboardCurrentUser() -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return usersService.onboardUser(with: currentUserId)
    }
    
    func sendConfirmationEmailToCurrentUser() -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return usersService.sendConfirmationEmail(by: currentUserId)
    }
    
    func destroyCurrentUserData() -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return  firstly {
            usersService.destroyUserData(by: currentUserId)
        }.done {
            UIFlowManager.set(point: .currencySetup, reached: false)
            UIFlowManager.set(point: .dataSetup, reached: false)
            self.router.route()
        }
    }
    
    func logout() -> Promise<Void> {
        let previousSession = userSessionManager.currentSession
        userSessionManager.forgetSession()
        notificationsCoordinator.cancelAllSceduledNotifications()
        UIFlowManager.set(point: .onboarding, reached: false)
        UIFlowManager.set(point: .currencySetup, reached: false)
        UIFlowManager.set(point: .dataSetup, reached: false)
        router.route()
        guard let session = previousSession else {
            return .value(())
        }
        return self.authenticationService.destroy(session: session)
    }
    
    func updateUserSubscription() -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        let form = UserSubscriptionUpdatingForm(userId: currentUserId, hasActiveSubscription: currentUserHasActiveSubscription)
        return usersService.updateUserSubscription(with: form)
    }
    
    func purchase(product: SKProduct) -> Promise<ApphudSubscription?> {
        return Promise { seal in
            Apphud.purchase(product) { result in
                seal.resolve(result.subscription, result.error)
            }
        }
    }
    
    func restoreSubscriptions() -> Promise<[ApphudSubscription]?> {
        return Promise { seal in
            Apphud.restorePurchases { subscriptions, nonRenewingPurchases, error in
                seal.resolve(subscriptions, error)
            }
        }
    }
    
    func silentRestoreSubscriptions() -> Promise<Void> {
        return Promise { seal in
            Apphud.restorePurchases { subscriptions, nonRenewingPurchases, error in
                seal.fulfill(())
            }
        }
    }
    
    func checkIntroductoryEligibility() -> Promise<[String : Bool]> {
        return Promise { Apphud.checkEligibilitiesForIntroductoryOffers(products: self.subscriptionProducts, callback: $0.fulfill) }
    }
}

extension AccountCoordinator {
    var activePremiumMonthly: ApphudSubscription? {
        return getActiveSubscription(.premium(.month))
    }
    
    var activePremiumSixMonths: ApphudSubscription? {
        return getActiveSubscription(.premium(.sixMonths))
    }
    
    var activePremiumYearly: ApphudSubscription? {
        return getActiveSubscription(.premium(.year))
    }
    
    var activePremiumUnlimitedCIS: ApphudSubscription? {
        return getActiveSubscription(.premiumUnlimited(.cis))
    }
    
    var activePremiumUnlimitedNonCIS: ApphudSubscription? {
        return getActiveSubscription(.premiumUnlimited(.nonCis))
    }
    
    var activePlatinumMonthly: ApphudSubscription? {
        return getActiveSubscription(.platinum(.month))
    }
    
    var activePlatinumYearly: ApphudSubscription? {
        return getActiveSubscription(.platinum(.year))
    }
    
    var activePlatinumPureMonthly: ApphudSubscription? {
        return getActiveSubscription(.platinumPure(.month))
    }
    
    var activePlatinumPureYearly: ApphudSubscription? {
        return getActiveSubscription(.platinumPure(.year))
    }
}

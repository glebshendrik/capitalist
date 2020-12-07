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
    case subscriptionError
}

class AccountCoordinator : AccountCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let authenticationService: AuthenticationServiceProtocol
    private let usersService: UsersServiceProtocol
    private let router: ApplicationRouterProtocol
    private let notificationsCoordinator: NotificationsCoordinatorProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    private let saltEdgeManager: SaltEdgeManagerProtocol
    private let saltEdgeCustomersService: SaltEdgeCustomersServiceProtocol
    
    var currentSession: Session? {
        return userSessionManager.currentSession
    }
    
    var hasActiveSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return subscription != nil || hasPremiumUnlimitedSubscription
        #endif
    }
    
    var premiumFeaturesAvailable: Bool {
        return hasPremiumSubscription || hasPlatinumSubscription
    }
    
    var platinumFeaturesAvailable: Bool {
        return hasPlatinumSubscription
    }

    var hasPremiumSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return
            hasPremiumUnlimitedSubscription ||
            isActive(.premium(.month)) ||
            isActive(.premium(.year)) ||
            isActive(.premium(.sixMonths))
        #endif
    }
    
    var hasPremiumUnlimitedSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return
            isActive(.premiumUnlimited(.cis)) ||
            isActive(.premiumUnlimited(.nonCis))
        #endif
    }
    
    var hasPlatinumSubscription: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
            
        let hasPlatinum = isActive(.platinum(.month)) || isActive(.platinum(.year))
        
        let hasPlatinumPure = isActive(.platinumPure(.month)) || isActive(.platinumPure(.year))
                
        return hasPlatinum || (hasPremiumUnlimitedSubscription && hasPlatinumPure)
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
            return nil
        }
        
        return
            activePremiumMonthly ??
            activePremiumSixMonths ??
            activePremiumYearly
        #endif
    }
        
    var activeSubscriptionProduct: SKProduct? {
        #if targetEnvironment(simulator)
        return nil
        #else
        func subscriptionProduct() -> SKProduct? {
            guard
                let subscription = subscription
            else {
                return nil
            }
            return subscriptionProducts.first { $0.productIdentifier == subscription.productId }
        }
        
        if hasPlatinumSubscription {
            return subscriptionProduct()
        }
        
        if hasPremiumUnlimitedSubscription {
            return subscriptionProducts.first { SubscriptionProduct.isUnlimited($0.productIdentifier) }
        }
        
        return subscriptionProduct()
        #endif
    }
    
    var subscriptionProducts: [SKProduct] {
        return Apphud.products() ?? []
    }
    
    init(userSessionManager: UserSessionManagerProtocol,
         authenticationService: AuthenticationServiceProtocol,
         usersService: UsersServiceProtocol,
         router: ApplicationRouterProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol,
         analyticsManager: AnalyticsManagerProtocol,
         saltEdgeManager: SaltEdgeManagerProtocol,
         saltEdgeCustomersService: SaltEdgeCustomersServiceProtocol) {
        
        self.userSessionManager = userSessionManager
        self.authenticationService = authenticationService
        self.usersService = usersService
        self.router = router
        self.notificationsCoordinator = notificationsCoordinator
        self.analyticsManager = analyticsManager
        self.saltEdgeManager = saltEdgeManager
        self.saltEdgeCustomersService = saltEdgeCustomersService
    }
    
    private func isActive(_ product: SubscriptionProduct) -> Bool {
        guard
            !Apphud.isNonRenewingPurchaseActive(productIdentifier: product.id)
        else {
            return true
        }
        
        let activeSubscriptionProducts = Apphud.subscriptions()?.filtered({ (s) -> Bool in
            return s.isActive()
        }, map: { (sub) -> String in
            sub.productId
        }) ?? []
                
        return activeSubscriptionProducts.contains(product.id)
    }
    
    private func getActiveSubscription(_ product: SubscriptionProduct) -> ApphudSubscription? {
        return Apphud.subscriptions()?.first(where: { $0.isActive() && $0.productId == product.id })
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
            if user.hasActiveSubscription != self.hasActiveSubscription {
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
            UIFlowManager.set(point: .walletsSetup, reached: false)
            UIFlowManager.set(point: .dataSetup, reached: false)
            self.router.route()
        }
    }
    
    func logout() -> Promise<Void> {
        let previousSession = userSessionManager.currentSession
        userSessionManager.forgetSession()
        notificationsCoordinator.cancelAllSceduledNotifications()
        UIFlowManager.set(point: .onboarding, reached: false)
        UIFlowManager.set(point: .walletsSetup, reached: false)
        UIFlowManager.set(point: .dataSetup, reached: false)
        router.route()
        guard let session = previousSession else {
            return .value(())
        }
        return self.authenticationService.destroy(session: session)
    }
    
    func createSaltEdgeCustomer() -> Promise<SaltEdgeCustomer> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return saltEdgeCustomersService.createSaltEdgeCustomer(userId: currentUserId)
    }
    
    func updateUserSubscription() -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        let form = UserSubscriptionUpdatingForm(userId: currentUserId, hasActiveSubscription: hasActiveSubscription)
        return usersService.updateUserSubscription(with: form)
    }
    
    func purchase(product: SKProduct) -> Promise<ApphudPurchaseResult> {
        return Promise { seal in
            Apphud.purchase(product) { result in
                if let subscription = result.subscription,
                   subscription.isActive() {
                    seal.fulfill(result)
                }
                else if let nonRenewingPurchase = result.nonRenewingPurchase,
                        nonRenewingPurchase.isActive() {
                    seal.fulfill(result)
                }
                else {
                    seal.reject(result.error ?? AuthProviderError.subscriptionError)
                }
            }
        }
    }
    
    func restoreSubscriptions() -> Promise<Void> {
        return Promise { seal in
            Apphud.restorePurchases { _, _, error in
                if Apphud.hasActiveSubscription() {
                    seal.fulfill(())
                }
                else if self.isActive(.premiumUnlimited(.cis)) || self.isActive(.premiumUnlimited(.nonCis)) {
                    seal.fulfill(())
                }
                else {
                    seal.reject(error ?? AuthProviderError.subscriptionError)
                }
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

//
//  AccountCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import StoreKit
import ApphudSDK

protocol AccountCoordinatorProtocol {
    var currentSession: Session? { get }
    var currentUserHasActiveSubscription: Bool { get }
    var subscription: ApphudSubscription? { get }
    var subscriptionProducts: [SKProduct] { get }
    
    func joinAsGuest() -> Promise<Session>
    func authenticate(with form: SessionCreationForm) -> Promise<Session>
    func authenticate(with json: String) -> Promise<Session>
    func createAndAuthenticateUser(with userForm: UserCreationForm) -> Promise<Session>
    func updateUser(with userForm: UserUpdatingForm) -> Promise<Void>
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void>
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void>
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void>
    func loadCurrentUser() -> Promise<User>
    func logout() -> Promise<Void>
    func loadCurrentUserBudget() -> Promise<Budget>
    func onboardCurrentUser() -> Promise<Void>
    
    func updateUserSubscription() -> Promise<Void>
    func checkIntroductoryEligibility() -> Promise<[String : Bool]>
    func purchase(product: SKProduct) -> Promise<ApphudSubscription?>
    func restoreSubscriptions() -> Promise<[ApphudSubscription]?>
    func silentRestoreSubscriptions() -> Promise<Void>
}


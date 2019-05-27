//
//  AccountCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

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
    
    var currentSession: Session? {
        return userSessionManager.currentSession
    }
    
    init(userSessionManager: UserSessionManagerProtocol,
         authenticationService: AuthenticationServiceProtocol,
         usersService: UsersServiceProtocol,
         router: ApplicationRouterProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol) {
        
        self.userSessionManager = userSessionManager
        self.authenticationService = authenticationService
        self.usersService = usersService
        self.router = router
        self.notificationsCoordinator = notificationsCoordinator
    }
        
    func joinAsGuest() -> Promise<Session> {
        return authenticate(with: SessionCreationForm(email: nil, password: nil))
    }
    
    func authenticate(with form: SessionCreationForm) -> Promise<Session> {
        return  firstly {
                    authenticationService.authenticate(form: form)
                }.get { session in
                    self.userSessionManager.save(session: session)
                    self.router.route()
                }
    }
    
    func createAndAuthenticateUser(with userForm: UserCreationForm) -> Promise<Session> {
        return  firstly {
                    usersService.createUser(with: userForm)
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
        return usersService.loadUser(with: currentUserId)
    }
    
    func loadCurrentUserBudget() -> Promise<Budget> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return usersService.loadUserBudget(with: currentUserId)
    }
    
    func logout() -> Promise<Void> {
        let previousSession = userSessionManager.currentSession
        userSessionManager.forgetSession()
        notificationsCoordinator.cancelAllSceduledNotifications()
        router.route()
        guard let session = previousSession else {
            return .value(())
        }
        return self.authenticationService.destroy(session: session)
    }
}
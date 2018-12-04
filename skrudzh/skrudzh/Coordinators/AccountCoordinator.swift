//
//  AccountCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
        return authenticate(email: nil, password: nil)
    }
    
    func authenticate(email: String?, password: String?) -> Promise<Session> {
        return  firstly {
                    authenticationService.authenticate(email: email, password: password)
                }.get { session in
                    self.userSessionManager.save(session: session)
                    self.router.route()
                }
    }
    
    func createAndAuthenticateUser(with userForm: UserCreationForm) -> Promise<Session> {
        return  firstly {
                    usersService.createUser(with: userForm)
                }.then { user in
                    self.authenticate(email: userForm.email, password: userForm.password)
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
                    self.authenticate(email: resetPasswordForm.email, password: resetPasswordForm.newPassword)
                }.asVoid()
    }
    
    func createConfirmationCode(email: String) -> Promise<Void> {
        return usersService.createConfirmationCode(email: email)
    }
    
    func loadCurrentUser() -> Promise<User> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return usersService.loadUser(with: currentUserId)
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

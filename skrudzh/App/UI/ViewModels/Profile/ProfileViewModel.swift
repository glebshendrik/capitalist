//
//  ProfileViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ProfileViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var currentUser: User? = nil
    
    var user: User? {
        return currentUser
    }
    
    var isCurrentUserLoaded: Bool {
        return currentUser != nil
    }
    
    var shouldNotifyAboutRegistrationConfirmation: Bool {
        guard let user = currentUser, !user.guest else {
            return false
        }
        return !user.registrationConfirmed
    }
    
    var currentUserFirstname: String? {
        return currentUser?.firstname
    }
    
    var currentUserEmail: String? {
        return currentUser?.email
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return accountCoordinator.loadCurrentUser().get { user in
            self.currentUser = user
        }.asVoid()
    }
    
    func logOut() -> Promise<Void> {
        return accountCoordinator.logout()
    }
}

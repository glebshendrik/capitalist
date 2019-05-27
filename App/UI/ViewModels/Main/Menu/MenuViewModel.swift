//
//  MenuViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class MenuViewModel {
    
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var currentUser: User? = nil
    
    var isCurrentUserLoaded: Bool {
        return currentUser != nil
    }
    
    var isCurrentUserGuest: Bool {
        guard let user = currentUser else {
            return true
        }
        return user.guest
    }    
    
    var shouldNotifyAboutRegistrationConfirmation: Bool {
        guard let user = currentUser, !user.guest else {
            return false
        }
        return !user.registrationConfirmed
    }
    
    var profileTitle: String? {
        var firstname = currentUser?.firstname
        if firstname != nil && firstname!.trimmed.isEmpty {
            firstname = nil
        }
        return firstname ?? currentUser?.email
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return accountCoordinator.loadCurrentUser().done { user in
            self.currentUser = user
        }.asVoid()
    }
}

//
//  MenuViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
    
    var isRegistrationConfirmed: Bool {
        guard let user = currentUser else {
            return false
        }
        return user.registrationConfirmed
    }
    
    var currentUserName: String? {
        return currentUser?.fullname
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

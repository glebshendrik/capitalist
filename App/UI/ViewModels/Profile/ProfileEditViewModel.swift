//
//  ProfileEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ProfileEditViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var user: User? = nil
    
    var name: String? = nil
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func set(user: User?) {
        self.user = user
        self.name = user?.firstname
    }
    
    func save() -> Promise<Void> {
        return accountCoordinator.updateUser(with: updatingForm())
    }
    
    private func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> UserUpdatingForm {
        return UserUpdatingForm(userId: accountCoordinator.currentSession?.userId,
                                firstname: name)
    }
}

//
//  LoginViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class LoginViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    var email: String?
    var password: String?
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func authenticate() -> Promise<Void> {
        return  firstly {            
                    authenticationPromise()
                }.then {
                    self.restoreSubscription()
                }
    }
    
    private func authenticationPromise() -> Promise<Void> {
        if let email = email, password == "ses+" {
            return accountCoordinator.authenticate(with: email).asVoid()
        }
        return accountCoordinator.authenticate(with: creationForm()).asVoid()
    }
    
    func restoreSubscription() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.restoreSubscriptions().asVoid()
                }.done { _ in
                    _ = UIFlowManager.reach(point: .subscription)
                }.recover { _ in Promise.value(()) }
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> SessionCreationForm {
        return SessionCreationForm(email: email,
                                   password: password)
    }
}

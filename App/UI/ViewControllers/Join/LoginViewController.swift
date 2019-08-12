//
//  LoginViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import StaticTableViewController
import SwiftMessages

class LoginViewController : FormSubmitViewController {
    
    var viewModel: LoginViewModel!
    private var delegate: LoginTableControllerDelegate?
    var tableController: LoginTableController!
    
    override var formTitle: String { return "Вход" }
    override var saveErrorMessage: String { return "Ошибка при входе" }
    
    override func registerFormFields() -> [String : FormField] {
        return [SessionCreationForm.CodingKeys.email.rawValue : tableController.loginField,
                SessionCreationForm.CodingKeys.password.rawValue : tableController.passwordField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? LoginTableController
        self.tableController.delegate = self
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.authenticate()
    }
    
    override func handleSave(_ error: Error) {
        switch error {
        case APIRequestError.notAuthorized:
            self.messagePresenterManager.show(validationMessage: "Неверный email или пароль")
        default:
            super.handleSave(error)
        }
    }
}

extension LoginViewController : LoginTableControllerDelegate {
    func didChange(login: String?) {
        viewModel.email = login
    }
    
    func didChange(password: String?) {
        viewModel.password = password
    }
    
    func didTapForgotPassword() {
        push(factory.forgotPasswordViewController())
    }
    
    func didTapSave() {
        save()
    }
}

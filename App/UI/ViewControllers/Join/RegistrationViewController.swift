//
//  RegistrationViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class RegistrationViewController : FormSubmitViewController {
    
    var viewModel: RegistrationViewModel!
    var tableController: RegistrationTableController!
    
    override var formTitle: String {
        return NSLocalizedString("Регистрация", comment: "Регистрация")
    }
    
    override var saveErrorMessage: String {
        return NSLocalizedString("Ошибка при регистрации", comment: "Ошибка при регистрации")        
    }
        
    override func registerFormFields() -> [String : FormField] {
        return [UserCreationForm.CodingKeys.firstname.rawValue : tableController.nameField,
                UserCreationForm.CodingKeys.email.rawValue : tableController.emailField,
                UserCreationForm.CodingKeys.password.rawValue : tableController.passwordField,
                UserCreationForm.CodingKeys.passwordConfirmation.rawValue : tableController.confirmationField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? RegistrationTableController
        self.tableController.delegate = self
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.register()
    }
}

extension RegistrationViewController : RegistrationTableControllerDelegate {
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(email: String?) {
        viewModel.email = email
    }
    
    func didChange(password: String?) {
        viewModel.password = password
    }
    
    func didChange(passwordConfirmation: String?) {
        viewModel.passwordConfirmation = passwordConfirmation
    }
    
    func didTapSave() {
        save()
    }
    
    func didTapSignIn() {
        push(factory.loginViewController())
    }
    
    func didAppear() {
         
    }
}

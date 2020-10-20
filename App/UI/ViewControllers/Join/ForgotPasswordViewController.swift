//
//  ForgotPasswordViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class ForgotPasswordViewController : FormSubmitViewController {
    
    var viewModel: ForgotPasswordViewModel!
    var tableController: ForgotPasswordTableController!
    
    override var formTitle: String {
        return NSLocalizedString("Восстановление пароля", comment: "Восстановление пароля")
    }
    
    override var saveErrorMessage: String {
        return NSLocalizedString("Ошибка при создании кода восстановления пароля", comment: "Ошибка при создании кода восстановления пароля")
    }
    
    override func registerFormFields() -> [String : FormField] {
        return [PasswordResetCodeForm.CodingKeys.email.rawValue : tableController.emailField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ForgotPasswordTableController
        self.tableController.delegate = self
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.createCode()
    }
    
    override func handleSave(_ error: Error) {
        switch error {
        case APIRequestError.notFound:
            self.messagePresenterManager.show(validationMessage: NSLocalizedString("Пользователь с таким адресом не найден", comment: "Пользователь с таким адресом не найден"))
        default:
            super.handleSave(error)
        }
    }
    
    override func didSave() {
        showResetPasswordScreen()
    }
    
    func showResetPasswordScreen() {
        messagePresenterManager.show(navBarMessage: NSLocalizedString("Мы отправили код для смены пароля на ваш Email", comment: "Мы отправили код для смены пароля на ваш Email"), theme: .success)
        push(factory.resetPasswordViewController(email: viewModel.email))
    }    
}

extension ForgotPasswordViewController : ForgotPasswordTableControllerDelegate {
    func didChange(email: String?) {
        viewModel.email = email
    }
    
    func didTapSave() {
        save()
    }
    
    func didAppear() {
         
    }
}

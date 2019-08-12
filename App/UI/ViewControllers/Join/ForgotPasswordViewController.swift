//
//  ForgotPasswordViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class ForgotPasswordViewController : FormSubmitViewController {
    
    var viewModel: ForgotPasswordViewModel!
    var tableController: ForgotPasswordTableController!
    
    override var formTitle: String { return "Восстановление пароля" }
    override var saveErrorMessage: String { return "Ошибка при создании кода восстановления пароля" }
    
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
            self.messagePresenterManager.show(validationMessage: "Пользователь с таким адресом не найден")
        default:
            super.handleSave(error)
        }
    }
    
    override func didSave() {
        showResetPasswordScreen()
    }
    
    func showResetPasswordScreen() {
        messagePresenterManager.show(navBarMessage: "Мы отправили код для смены пароля на ваш Email", theme: .success)
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
}

//
//  ResetPasswordViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class ResetPasswordViewController : FormSubmitViewController {
    
    var viewModel: ResetPasswordViewModel!
    var tableController: ResetPasswordTableController!
    
    override var formTitle: String { return NSLocalizedString("Смена пароля", comment: "Смена пароля") }
    override var saveErrorMessage: String { return NSLocalizedString("Ошибка при изменении пароля", comment: "Ошибка при изменении пароля") }
    
    func set(email: String?) {
        self.viewModel.email = email
    }
        
    override func registerFormFields() -> [String : FormField] {
        return [ResetPasswordForm.CodingKeys.passwordResetCode.rawValue : tableController.codeField,
                ResetPasswordForm.CodingKeys.password.rawValue : tableController.passwordField,
                ResetPasswordForm.CodingKeys.passwordConfirmation.rawValue : tableController.confirmationField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ResetPasswordTableController
        self.tableController.delegate = self
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.resetPassword()
    }
    
    override func handleSave(_ error: Error) {
        switch error {
        case APIRequestError.forbidden:
            self.messagePresenterManager.show(validationMessage: NSLocalizedString("Код восстановления неверный или больше не действует", comment: "Код восстановления неверный или больше не действует"))
        case APIRequestError.notFound:
            self.messagePresenterManager.show(validationMessage: NSLocalizedString("Пользователь с таким адресом не найден", comment: "Пользователь с таким адресом не найден"))
        default:
            super.handleSave(error)
        }
    }
}

extension ResetPasswordViewController : ResetPasswordTableControllerDelegate {    
    func didChange(code: String?) {
        viewModel.passwordResetCode = code
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
    
    func didAppear() {
         
    }
}

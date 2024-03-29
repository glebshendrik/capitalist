//
//  ChangePasswordViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 06/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class ChangePasswordViewController : FormSubmitViewController {
    
    var viewModel: ChangePasswordViewModel!
    var tableController: ChangePasswordTableController!
    
    override var formTitle: String { return NSLocalizedString("Смена пароля", comment: "Смена пароля") }
    override var saveErrorMessage: String { return NSLocalizedString("Ошибка при изменении пароля", comment: "Ошибка при изменении пароля") }
    
    override func registerFormFields() -> [String : FormField] {
        return [ChangePasswordForm.CodingKeys.oldPassword.rawValue : tableController.oldPasswordField,
                "password" : tableController.newPasswordField,
                ChangePasswordForm.CodingKeys.newPasswordConfirmation.rawValue : tableController.confirmationField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ChangePasswordTableController
        self.tableController.delegate = self
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.resetPassword()
    }
    
    override func handleSave(_ error: Error) {
        switch error {
        case APIRequestError.forbidden:
            tableController.oldPasswordField.addError(message: NSLocalizedString("Старый пароль неверен", comment: "Старый пароль неверен"))
        default:
            super.handleSave(error)
        }
    }
    
    override func didSave() {
        messagePresenterManager.show(navBarMessage: NSLocalizedString("Пароль успешно изменен", comment: "Пароль успешно изменен"), theme: .success)
        navigationController?.popViewController(animated: true)
    }
}

extension ChangePasswordViewController : ChangePasswordTableControllerDelegate {
    func didChange(oldPassword: String?) {
        viewModel.oldPassword = oldPassword
    }
    
    func didChange(newPassword: String?) {
        viewModel.newPassword = newPassword
    }
    
    func didChange(newPasswordConfirmation: String?) {
        viewModel.newPasswordConfirmation = newPasswordConfirmation
    }
    
    func didTapSave() {
        save()
    }
    
    func didAppear() {
         
    }
}

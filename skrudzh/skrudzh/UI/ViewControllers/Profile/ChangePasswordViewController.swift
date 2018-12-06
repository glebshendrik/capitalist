//
//  ChangePasswordViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 06/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages

class ChangePasswordViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordConfirmationTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: ChangePasswordViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapChangePasswordButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        changePasswordButton.isEnabled = false
        
        firstly {
            viewModel.changePasswordWith(oldPassword: oldPasswordTextField.text?.trimmed,
                                         newPassword: newPasswordTextField.text?.trimmed,
                                         newPasswordConfirmation: newPasswordConfirmationTextField.text?.trimmed)
            }.catch { error in
                switch error {
                case ChangePasswordError.validation(let validationResults):
                    self.show(validationResults: validationResults)
                case APIRequestError.unprocessedEntity(let errors):
                    self.show(errors: errors)
                default:
                    self.messagePresenterManager.show(navBarMessage: "Невозможно изменить пароль", theme: .error)
                }
            }.finally {
                self.setActivityIndicator(hidden: true)
                self.changePasswordButton.isEnabled = true
        }
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func show(validationResults: [ChangePasswordForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = validationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func validationMessageFor(key: ChangePasswordForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.oldPassword, .required):
            return "Укажите текущий пароль"
        case (.oldPassword, _):
            return "Некорректный текущий пароль"
        case (.newPassword, .required):
            return "Укажите новый пароль"
        case (.newPassword, _):
            return "Некорректный новый пароль"
        case (.newPasswordConfirmation, .required):
            return "Подтвердите новый пароль"
        case (.newPasswordConfirmation, .notEqual(to: ChangePasswordForm.CodingKeys.newPassword)):
            return "Подтверждение не совпадает с новым паролем"
        case (.newPasswordConfirmation, _):
            return "Некорректное подтверждение нового пароля"
        }
    }
}

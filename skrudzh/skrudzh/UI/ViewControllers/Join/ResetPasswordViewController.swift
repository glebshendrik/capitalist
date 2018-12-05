//
//  ResetPasswordViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages

protocol ResetPasswordInputProtocol {
    func set(email: String?)
}

class ResetPasswordViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol, ResetPasswordInputProtocol {
    
    @IBOutlet weak var passwordResetCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: ResetPasswordViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    private var email: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    func set(email: String?) {
        self.email = email
    }
    
    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        
        setActivityIndicator(hidden: false)
        resetPasswordButton.isEnabled = false
        
        firstly {
            viewModel.resetPasswordWith(email: email,
                                        passwordResetCode: passwordResetCodeTextField.text,
                                        password: passwordTextField.text,
                                        passwordConfirmation: passwordConfirmationTextField.text)
            }.catch { error in
                switch error {
                case ResetPasswordError.validation(let validationResults):
                    self.show(validationResults: validationResults)
                case ResetPasswordError.emailInvalid:
                    self.messagePresenterManager.show(navBarMessage: "Не удалось изменить пароль", theme: .error)
                case APIRequestError.forbidden:
                    self.messagePresenterManager.show(navBarMessage: "Код восстановления больше не действует. Вернитесь назад и сгенерируйте новый", theme: .error)
                case APIRequestError.notAuthorized:
                    self.messagePresenterManager.show(navBarMessage: "Пароль изменен, но войти с ним не удалось. Возможно изменился email", theme: .error)
                case APIRequestError.unprocessedEntity(let errors):
                    self.show(errors: errors)
                default:
                    self.messagePresenterManager.show(navBarMessage: "Ошибка при изменении пароля", theme: .error)
                }
            }.finally {
                self.setActivityIndicator(hidden: true)
                self.resetPasswordButton.isEnabled = true
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
    
    private func show(validationResults: [ResetPasswordForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = validationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func validationMessageFor(key: ResetPasswordForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.passwordResetCode, .required):
            return "Укажите код восстановления"
        case (.passwordResetCode, _):
            return "Некорректный код восстановления"
        case (.password, .required):
            return "Укажите пароль"
        case (.password, _):
            return "Некорректный пароль"
        case (.passwordConfirmation, .required):
            return "Подтвердите пароль"
        case (.passwordConfirmation, .notEqual(to: UserCreationForm.CodingKeys.password)):
            return "Подтверждение не совпадает с паролем"
        case (.passwordConfirmation, _):
            return "Некорректное подтверждение пароля"
        }
    }
}

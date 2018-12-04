//
//  RegistrationViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages

class RegistrationViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: RegistrationViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        
        setActivityIndicator(hidden: false)
        registerButton.isEnabled = false
        
        firstly {
            viewModel.registerWith(firstname: self.firstnameTextField.text,
                                   email: self.emailTextField.text,
                                   password: self.passwordTextField.text,
                                   passwordConfirmation: self.passwordConfirmationTextField.text)
        }.catch { error in
            switch error {
            case RegistrationError.validation(let validationResults):
                self.show(validationResults: validationResults)
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                return
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.registerButton.isEnabled = true
        }
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    private func show(errors: [String: String]) {
        for (attribute, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: "\(attribute) \(validationMessage)")
        }
    }
    
    private func show(validationResults: [UserCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = validationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func validationMessageFor(key: UserCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.email, .required):
            return "Укажите Email"
        case (.email, .invalid):
            return "Некорректный Email"
        case (.email, _):
            return "Некорректный Email"
        case (.password, .required):
            return "Укажите пароль"
        case (.password, _):
            return "Некорректный пароль"
        case (.passwordConfirmation, .required):
            return "Подтвердите пароль"
        case (.passwordConfirmation, .notEqual(to: .password)):
            return "Подтверждение не совпадает с паролем"
        case (.passwordConfirmation, _):
            return "Некорректняое подтверждение пароля"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

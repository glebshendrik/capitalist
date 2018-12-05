//
//  LoginViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages

class LoginViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: LoginViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        loginButton.isEnabled = false
        
        firstly {
            viewModel.loginWith(email: self.emailTextField.text?.trimmed,
                                password: self.passwordTextField.text?.trimmed)
        }.catch { error in
            switch error {
            case LoginError.validation(let validationResults):
                self.show(validationResults: validationResults)
            case APIRequestError.notAuthorized:
                self.messagePresenterManager.show(validationMessage: "Неверный email или пароль")
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при входе", theme: .error)
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.loginButton.isEnabled = true
        }
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    private func show(validationResults: [SessionCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = validationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func validationMessageFor(key: SessionCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
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
        }
    }
}

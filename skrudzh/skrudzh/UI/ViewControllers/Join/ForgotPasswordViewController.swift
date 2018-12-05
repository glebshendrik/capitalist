//
//  ForgotPasswordViewController.swift
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

protocol ForgotPasswordOutputProtocol {
    var email: String? { get }
}

class ForgotPasswordViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol, ForgotPasswordOutputProtocol {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var createPasswordResetCodeButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: ForgotPasswordViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var email: String? {
        return emailTextField.text?.trimmed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapCreatePasswordResetCodeButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        createPasswordResetCodeButton.isEnabled = false
        
        firstly {
            viewModel.createPasswordResetCodeWith(email: email)
        }.done {
            self.showResetPasswordScreen()
        }
        .catch { error in
            switch error {
            case ForgotPasswordError.validation(let validationResults):
                self.show(validationResults: validationResults)
            case APIRequestError.notFound:
                self.messagePresenterManager.show(navBarMessage: "Пользователь с таким адресом не найден", theme: .error)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при создании кода восстановления пароля", theme: .error)
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.createPasswordResetCodeButton.isEnabled = true
        }
    }
    
    func showResetPasswordScreen() {
        self.messagePresenterManager.show(navBarMessage: "Мы отправили код для смены пароля на ваш Email", theme: .success)
        performSegue(withIdentifier: "ShowResetPasswordScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ResetPasswordInputProtocol,
            segue.identifier == "ShowResetPasswordScreen" {
            destination.set(email: email)
        }
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    private func show(validationResults: [PasswordResetCodeForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = validationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func validationMessageFor(key: PasswordResetCodeForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.email, .required):
            return "Укажите Email"
        case (.email, _):
            return "Некорректный Email"
        }
    }
}

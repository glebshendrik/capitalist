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

class RegistrationViewController : StaticDataTableViewController {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: RegistrationViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        
        setActivityIndicator(hidden: false)
        registerButton.isEnabled = false
        
        firstly {
            after(seconds: 5)
        }.then {
            self.viewModel.registerWith(firstname: self.firstnameTextField.text,
                                        email: self.emailTextField.text,
                                        password: self.passwordTextField.text,
                                        passwordConfirmation: self.passwordConfirmationTextField.text)
        }
        .catch { error in
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
        reloadData(animated: animated, insert: .bottom, reload: .fade, delete: .top)
    }
    
    private func show(errors: [String: String]) {
        for (attribute, validationMessage) in errors {
            show(validationMessage: "\(attribute) \(validationMessage)")
        }
    }
    
    private func show(validationResults: [UserCreationForm.CodingKeys: [ValidationErrorReason]]) {
        for (key, reasons) in validationResults {
            for reason in reasons {
                let message = validationMessageFor(key: key, reason: reason)
                show(validationMessage: message)
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
    
    private func show(validationMessage: String) {
        var config = SwiftMessages.Config()
        
        // Slide up from the bottom.
        config.presentationStyle = .bottom
        
        // Display in a window at the specified window level: UIWindow.Level.statusBar
        // displays over the status bar while UIWindow.Level.normal displays under.
        config.presentationContext = .automatic
        
        // Disable the default auto-hiding behavior.
        config.duration = .seconds(seconds: 1.5)
        
        // Dim the background like a popover view. Hide when the background is tapped.
        config.dimMode = .gray(interactive: false)
        
        // Disable the interactive pan-to-hide gesture.
        config.interactiveHide = false
        
        // Specify a status bar style to if the message is displayed directly under the status bar.
        config.preferredStatusBarStyle = .lightContent
        
        // Specify one or more event listeners to respond to show and hide events.
//        config.eventListeners.append() { event in
//            if case .didHide = event { print("yep") }
//        }
        
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(title: "", body: validationMessage)
        view.button?.isHidden = true
        
        SwiftMessages.pauseBetweenMessages = 0.01
        SwiftMessages.show(config: config, view: view)
    }
}

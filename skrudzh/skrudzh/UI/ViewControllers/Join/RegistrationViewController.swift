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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        registerButton.isEnabled = false
        
        firstly {
            viewModel.registerWith(firstname: self.firstnameTextField.text?.trimmed,
                                   email: self.emailTextField.text?.trimmed,
                                   password: self.passwordTextField.text?.trimmed,
                                   passwordConfirmation: self.passwordConfirmationTextField.text?.trimmed)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при регистрации", theme: .error)
            self.validateUI()
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.registerButton.isEnabled = true
        }
    }
    
    @IBAction func didChangeText(_ sender: UITextField) {
        didChangeEditing(sender)
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
}

extension RegistrationViewController {
    
    typealias FieldSettings = (background: UIColor, border: UIColor, borderWidth: CGFloat)
    
    private func registerTextFields() {
        viewModel.register(emailTextField,
                           attributeName: UserCreationForm.CodingKeys.email.stringValue,
                           codingKey: UserCreationForm.CodingKeys.email)
        viewModel.register(passwordTextField,
                           attributeName: UserCreationForm.CodingKeys.password.stringValue,
                           codingKey: UserCreationForm.CodingKeys.password)
        viewModel.register(passwordConfirmationTextField,
                           attributeName: UserCreationForm.CodingKeys.passwordConfirmation.stringValue,
                           codingKey: UserCreationForm.CodingKeys.passwordConfirmation)
    }
    
    private func validateUI() {
        viewModel.fieldViewModels.forEach { fieldViewModel in
            if let textField = fieldViewModel.field as? UITextField {
                set(textField: textField, valid: fieldViewModel.valid)
            }
        }
    }
    
    private func set(textField: UITextField, valid: Bool) {
        let settings = valid ? validSettings() : invalidSettings()
        
        textField.superview?.backgroundColor = settings.background
        textField.superview?.borderColor = settings.border
        textField.superview?.borderWidth = settings.borderWidth
    }
    
    private func validSettings() -> FieldSettings {
        return (background: UIColor(red: 0.95, green: 0.96, blue: 1, alpha: 1),
                border: UIColor.clear,
                borderWidth: 0)
    }
    
    private func invalidSettings() -> FieldSettings {
        return (background: UIColor(red: 1, green: 0.98, blue: 0.98, alpha: 1),
                border: UIColor(red: 1, green: 0.22, blue: 0.27, alpha: 1),
                borderWidth: 1)
    }
    
    private func show(errors: [String]) {
        for error in errors {
            messagePresenterManager.show(validationMessage: error)
        }
    }
}

extension RegistrationViewController : UITextFieldDelegate {
    
    private func didChangeEditing(_ textField: UITextField) {
        if let fieldViewModel = viewModel.fieldViewModelBy(field: textField) {
            fieldViewModel.removeErrors()
            set(textField: textField, valid: fieldViewModel.valid)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let fieldViewModel = viewModel.fieldViewModelBy(field: textField) {
            show(errors: fieldViewModel.errors)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

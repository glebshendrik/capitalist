//
//  LoginTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol LoginTableControllerDelegate {
    func didChange(login: String?)
    func didChange(password: String?)
    func didTapForgotPassword()
    func didTapSave()
}

class LoginTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var loginField: FormTextField!
    @IBOutlet weak var passwordField: FormTextField!
    
    var delegate: LoginTableControllerDelegate?
    
    override var saveButtonTitle: String { return "Войти" }
    
    override func setupUI() {
        super.setupUI()
        setupLoginField()
        setupPasswordField()
    }
    
    private func setupLoginField() {
        loginField.placeholder = "Email"
        loginField.imageName = "email-icon"
        loginField.textField.textContentType = UITextContentType.emailAddress
        loginField.textField.keyboardType = UIKeyboardType.emailAddress
        loginField.textField.autocapitalizationType = UITextAutocapitalizationType.none
        loginField.textField.autocorrectionType = UITextAutocorrectionType.no
        loginField.textField.inputAccessoryView = saveButton
        loginField.didChange { [weak self] text in
            self?.delegate?.didChange(login: text)
        }
    }
    
    private func setupPasswordField() {
        passwordField.placeholder = "Пароль"
        passwordField.imageName = "password-icon"
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.textContentType = UITextContentType.password
        passwordField.textField.inputAccessoryView = saveButton
        passwordField.didChange { [weak self] text in
            self?.delegate?.didChange(password: text)
        }
    }
    
    @IBAction func didTapForgotPassword(_ sender: UIButton) {
        delegate?.didTapForgotPassword()
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
}

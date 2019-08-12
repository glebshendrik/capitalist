//
//  RegistrationTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol RegistrationTableControllerDelegate {
    func didChange(name: String?)
    func didChange(email: String?)
    func didChange(password: String?)
    func didChange(passwordConfirmation: String?)
    func didTapSave()
}

class RegistrationTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var emailField: FormTextField!
    @IBOutlet weak var passwordField: FormTextField!
    @IBOutlet weak var confirmationField: FormTextField!
    
    var delegate: RegistrationTableControllerDelegate?
    
    override var saveButtonTitle: String { return "Зарегистрироваться" }    
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupEmailField()
        setupPasswordField()
        setupPasswordConfirmationField()
    }
    
    private func setupNameField() {
        register(responder: nameField.textField)
        nameField.textField.inputAccessoryView = saveButton
        nameField.placeholder = "Имя"
        nameField.imageName = "name-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    private func setupEmailField() {
        register(responder: emailField.textField)
        setupAsEmail(emailField)
        emailField.placeholder = "Email"
        emailField.imageName = "email-icon"
        emailField.didChange { [weak self] text in
            self?.delegate?.didChange(email: text)
        }
    }
    
    private func setupPasswordField() {
        register(responder: passwordField.textField)
        setupAsSecure(passwordField)
        passwordField.placeholder = "Пароль"
        passwordField.imageName = "password-icon"
        passwordField.didChange { [weak self] text in
            self?.delegate?.didChange(password: text)
        }
    }
    
    private func setupPasswordConfirmationField() {
        register(responder: confirmationField.textField)
        setupAsSecure(confirmationField)
        confirmationField.placeholder = "Пароль еще раз"
        confirmationField.imageName = "password-icon"
        confirmationField.didChange { [weak self] text in
            self?.delegate?.didChange(passwordConfirmation: text)
        }
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
}

//
//  ResetPasswordTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ResetPasswordTableControllerDelegate {
    func didChange(code: String?)
    func didChange(password: String?)
    func didChange(passwordConfirmation: String?)
    func didTapSave()
}

class ResetPasswordTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var codeField: FormTextField!
    @IBOutlet weak var passwordField: FormTextField!
    @IBOutlet weak var confirmationField: FormTextField!
    
    var delegate: ResetPasswordTableControllerDelegate?
    
    override var saveButtonTitle: String { return "Сменить пароль" }
    
    override func setupUI() {
        super.setupUI()
        setupCodeField()
        setupPasswordField()
        setupPasswordConfirmationField()
    }
    
    private func setupCodeField() {
        register(responder: codeField.textField)
        codeField.textField.inputAccessoryView = saveButton
        codeField.placeholder = "Код подтверждения"
        codeField.imageName = "password-icon"
        codeField.didChange { [weak self] text in
            self?.delegate?.didChange(code: text)
        }
    }
    
    private func setupPasswordField() {
        register(responder: passwordField.textField)
        setupAsSecure(passwordField)
        passwordField.placeholder = "Новый пароль"
        passwordField.imageName = "password-icon"
        passwordField.didChange { [weak self] text in
            self?.delegate?.didChange(password: text)
        }
    }
    
    private func setupPasswordConfirmationField() {
        register(responder: confirmationField.textField)
        setupAsSecure(confirmationField)
        confirmationField.placeholder = "Новый пароль еще раз"
        confirmationField.imageName = "password-icon"
        confirmationField.didChange { [weak self] text in
            self?.delegate?.didChange(passwordConfirmation: text)
        }
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
}

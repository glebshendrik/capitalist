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
    @IBOutlet weak var resetPasswordCell: UITableViewCell!
    @IBOutlet weak var resetPasswordButton: HighlightButton!
    
    var delegate: ResetPasswordTableControllerDelegate?
    
    override var saveButtonTitle: String { return NSLocalizedString("Сменить пароль", comment: "Сменить пароль") }
    override var saveButtonInForm: UIButton? {
        return resetPasswordButton
    }
    
    override func setupUI() {
        super.setupUI()
        setupCodeField()
        setupPasswordField()
        setupPasswordConfirmationField()
    }
    
    private func setupCodeField() {
        register(responder: codeField.textField)
        codeField.textField.inputAccessoryView = saveButton
        codeField.placeholder = NSLocalizedString("Код подтверждения", comment: "Код подтверждения")
        codeField.imageName = "password-icon"
        codeField.didChange { [weak self] text in
            self?.delegate?.didChange(code: text)
        }
    }
    
    private func setupPasswordField() {
        register(responder: passwordField.textField)
        setupAsSecure(passwordField)
        passwordField.placeholder = NSLocalizedString("Новый пароль", comment: "Новый пароль")
        passwordField.imageName = "password-icon"
        passwordField.didChange { [weak self] text in
            self?.delegate?.didChange(password: text)
        }
    }
    
    private func setupPasswordConfirmationField() {
        register(responder: confirmationField.textField)
        setupAsSecure(confirmationField)
        confirmationField.placeholder = NSLocalizedString("Новый пароль еще раз", comment: "Новый пароль еще раз")
        confirmationField.imageName = "password-icon"
        confirmationField.didChange { [weak self] text in
            self?.delegate?.didChange(passwordConfirmation: text)
        }
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
    
    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        delegate?.didTapSave()
    }
}

//
//  ChangePasswordTableController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ChangePasswordTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didChange(oldPassword: String?)
    func didChange(newPassword: String?)
    func didChange(newPasswordConfirmation: String?)
}

class ChangePasswordTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var oldPasswordField: FormTextField!
    @IBOutlet weak var newPasswordField: FormTextField!
    @IBOutlet weak var confirmationField: FormTextField!
    @IBOutlet weak var changePasswordButton: HighlightButton!
    
    weak var delegate: ChangePasswordTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
    
    override var saveButtonTitle: String { return NSLocalizedString("Сменить пароль", comment: "Сменить пароль") }
    override var saveButtonInForm: HighlightButton? {
        return changePasswordButton
    }
    
    override func setupUI() {
        super.setupUI()
        setupOldPasswordField()
        setupNewPasswordField()
        setupNewPasswordConfirmationField()
    }
    
    private func setupOldPasswordField() {
        register(responder: oldPasswordField.textField)
        setupAsSecure(oldPasswordField)
        oldPasswordField.placeholder = NSLocalizedString("Старый пароль", comment: "Старый пароль")
        oldPasswordField.imageName = "password-icon"
        oldPasswordField.didChange { [weak self] text in
            self?.delegate?.didChange(oldPassword: text)
        }
    }
    
    private func setupNewPasswordField() {
        register(responder: newPasswordField.textField)
        setupAsNewPassword(newPasswordField)
        newPasswordField.placeholder = NSLocalizedString("Новый пароль", comment: "Новый пароль")
        newPasswordField.imageName = "password-icon"
        newPasswordField.didChange { [weak self] text in
            self?.delegate?.didChange(newPassword: text)
        }
    }
    
    private func setupNewPasswordConfirmationField() {
        register(responder: confirmationField.textField)
        setupAsNewPassword(confirmationField)
        confirmationField.placeholder = NSLocalizedString("Новый пароль еще раз", comment: "Новый пароль еще раз")
        confirmationField.imageName = "password-icon"
        confirmationField.didChange { [weak self] text in
            self?.delegate?.didChange(newPasswordConfirmation: text)
        }
    }
    
    @IBAction func didTapChangePasswordButton(_ sender: Any) {
        delegate?.didTapSave()
    }
}

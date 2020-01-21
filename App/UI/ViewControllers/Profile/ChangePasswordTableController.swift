//
//  ChangePasswordTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ChangePasswordTableControllerDelegate {
    func didChange(oldPassword: String?)
    func didChange(newPassword: String?)
    func didChange(newPasswordConfirmation: String?)
    func didTapSave()
}

class ChangePasswordTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var oldPasswordField: FormTextField!
    @IBOutlet weak var newPasswordField: FormTextField!
    @IBOutlet weak var confirmationField: FormTextField!
    @IBOutlet weak var changePasswordButton: HighlightButton!
    
    var delegate: ChangePasswordTableControllerDelegate?
    
    override var saveButtonTitle: String { return "Сменить пароль" }
    override var saveButtonInForm: UIButton? {
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
        oldPasswordField.placeholder = "Старый пароль"
        oldPasswordField.imageName = "password-icon"
        oldPasswordField.didChange { [weak self] text in
            self?.delegate?.didChange(oldPassword: text)
        }
    }
    
    private func setupNewPasswordField() {
        register(responder: newPasswordField.textField)
        setupAsSecure(newPasswordField)
        newPasswordField.placeholder = "Новый пароль"
        newPasswordField.imageName = "password-icon"
        newPasswordField.didChange { [weak self] text in
            self?.delegate?.didChange(newPassword: text)
        }
    }
    
    private func setupNewPasswordConfirmationField() {
        register(responder: confirmationField.textField)
        setupAsSecure(confirmationField)
        confirmationField.placeholder = "Новый пароль еще раз"
        confirmationField.imageName = "password-icon"
        confirmationField.didChange { [weak self] text in
            self?.delegate?.didChange(newPasswordConfirmation: text)
        }
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
    
    @IBAction func didTapChangePasswordButton(_ sender: Any) {
        delegate?.didTapSave()
    }
}

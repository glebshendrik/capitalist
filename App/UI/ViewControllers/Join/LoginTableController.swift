//
//  LoginTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol LoginTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didChange(login: String?)
    func didChange(password: String?)
    func didTapForgotPassword()    
}

class LoginTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var loginField: FormTextField!
    @IBOutlet weak var passwordField: FormTextField!
    @IBOutlet weak var signInCell: UITableViewCell!
    @IBOutlet weak var signInButton: HighlightButton!
    
    var delegate: LoginTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
    
    override var saveButtonTitle: String { return NSLocalizedString("Войти", comment: "Войти") }
    override var saveButtonInForm: HighlightButton? {
        return signInButton
    }
    
    override func setupUI() {
        super.setupUI()
        setupLoginField()
        setupPasswordField()
    }
    
    private func setupLoginField() {
        register(responder: loginField.textField)
        setupAsEmail(loginField)
        loginField.placeholder = NSLocalizedString("Email", comment: "Email")
        loginField.imageName = "email-icon"
        loginField.didChange { [weak self] text in
            self?.delegate?.didChange(login: text)
        }
    }
    
    private func setupPasswordField() {
        register(responder: passwordField.textField)
        setupAsPassword(passwordField)
        passwordField.placeholder = NSLocalizedString("Пароль", comment: "Пароль")
        passwordField.imageName = "password-icon"
        passwordField.didChange { [weak self] text in
            self?.delegate?.didChange(password: text)
        }
    }
    
    @IBAction func didTapForgotPassword(_ sender: UIButton) {
        delegate?.didTapForgotPassword()
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        delegate?.didTapSave()
    }
}

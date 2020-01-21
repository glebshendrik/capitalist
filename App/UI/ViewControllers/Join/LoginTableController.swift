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
    @IBOutlet weak var signInCell: UITableViewCell!
    @IBOutlet weak var signInButton: HighlightButton!
    
    var delegate: LoginTableControllerDelegate?
    
    override var saveButtonTitle: String { return "Войти" }
    override var saveButtonInForm: UIButton? {
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
        loginField.placeholder = "Email"
        loginField.imageName = "email-icon"
        loginField.didChange { [weak self] text in
            self?.delegate?.didChange(login: text)
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
    
    @IBAction func didTapForgotPassword(_ sender: UIButton) {
        delegate?.didTapForgotPassword()
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        delegate?.didTapSave()
    }
}

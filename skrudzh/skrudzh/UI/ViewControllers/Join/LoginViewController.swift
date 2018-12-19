//
//  LoginViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages

class LoginViewController : StaticDataTableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: LoginViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        loginButton.isEnabled = false
        
        firstly {
            viewModel.loginWith(email: self.emailTextField.text?.trimmed,
                                password: self.passwordTextField.text?.trimmed)
        }.catch { error in
            switch error {
            case APIRequestError.notAuthorized:
                self.messagePresenterManager.show(validationMessage: "Неверный email или пароль")
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при входе", theme: .error)
            }
            self.validateUI()
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.loginButton.isEnabled = true
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

extension LoginViewController : FieldsViewControllerProtocol {
    
    var fieldsViewModel: FieldsViewModel {
        return viewModel
    }
    
    func registerFields() {
        fieldsViewModel.register(emailTextField,
                                 attributeName: SessionCreationForm.CodingKeys.email.stringValue,
                                 codingKey: SessionCreationForm.CodingKeys.email)
        fieldsViewModel.register(passwordTextField,
                                 attributeName: SessionCreationForm.CodingKeys.password.stringValue,
                                 codingKey: SessionCreationForm.CodingKeys.password)
    }
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

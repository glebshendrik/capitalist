//
//  LoginViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import StaticTableViewController
import SwiftMessages

class LoginViewController : StaticTableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var viewModel: LoginViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insertAnimation = .top
        deleteAnimation = .bottom
        registerFields()
        loaderImageView.showLoader()
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
        set(cells: activityIndicatorCell, hidden: hidden)
        reloadData(animated: animated)
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
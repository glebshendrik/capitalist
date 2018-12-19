//
//  RegistrationViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages

class RegistrationViewController : StaticDataTableViewController {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: RegistrationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        registerButton.isEnabled = false
        
        firstly {
            viewModel.registerWith(firstname: self.firstnameTextField.text?.trimmed,
                                   email: self.emailTextField.text?.trimmed,
                                   password: self.passwordTextField.text?.trimmed,
                                   passwordConfirmation: self.passwordConfirmationTextField.text?.trimmed)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при регистрации", theme: .error)
            self.validateUI()
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.registerButton.isEnabled = true
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

extension RegistrationViewController : FieldsViewControllerProtocol {
    
    var fieldsViewModel: FieldsViewModel {
        return viewModel
    }
    
    func registerFields() {
        fieldsViewModel.register(emailTextField,
                                 attributeName: UserCreationForm.CodingKeys.email.stringValue,
                                 codingKey: UserCreationForm.CodingKeys.email)
        fieldsViewModel.register(passwordTextField,
                                 attributeName: UserCreationForm.CodingKeys.password.stringValue,
                                 codingKey: UserCreationForm.CodingKeys.password)
        fieldsViewModel.register(passwordConfirmationTextField,
                                 attributeName: UserCreationForm.CodingKeys.passwordConfirmation.stringValue,
                                 codingKey: UserCreationForm.CodingKeys.passwordConfirmation)
    }
}

extension RegistrationViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

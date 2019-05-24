//
//  ResetPasswordViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import StaticTableViewController
import SwiftMessages

protocol ResetPasswordInputProtocol {
    func set(email: String?)
}

class ResetPasswordViewController : StaticTableViewController, ResetPasswordInputProtocol {
    
    @IBOutlet weak var passwordResetCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var viewModel: ResetPasswordViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    private var email: String?
    
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
    
    func set(email: String?) {
        self.email = email
    }
    
    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        resetPasswordButton.isEnabled = false
        
        firstly {
            viewModel.resetPasswordWith(email: email,
                                        passwordResetCode: passwordResetCodeTextField.text?.trimmed,
                                        password: passwordTextField.text?.trimmed,
                                        passwordConfirmation: passwordConfirmationTextField.text?.trimmed)
            }.catch { error in
                switch error {
                case APIRequestError.notFound:
                    self.messagePresenterManager.show(navBarMessage: "Пользователь с таким адресом не найден", theme: .error)
                default:
                    self.messagePresenterManager.show(navBarMessage: "Ошибка при изменении пароля", theme: .error)
                }
                self.validateUI()
            }.finally {
                self.setActivityIndicator(hidden: true)
                self.resetPasswordButton.isEnabled = true
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

extension ResetPasswordViewController : FieldsViewControllerProtocol {
    
    var fieldsViewModel: FieldsViewModel {
        return viewModel
    }
    
    func registerFields() {
        fieldsViewModel.register(passwordResetCodeTextField,
                                 attributeName: ResetPasswordForm.CodingKeys.passwordResetCode.stringValue,
                                 codingKey: ResetPasswordForm.CodingKeys.passwordResetCode)
        fieldsViewModel.register(passwordTextField,
                                 attributeName: ResetPasswordForm.CodingKeys.password.stringValue,
                                 codingKey: ResetPasswordForm.CodingKeys.password)
        fieldsViewModel.register(passwordConfirmationTextField,
                                 attributeName: ResetPasswordForm.CodingKeys.passwordConfirmation.stringValue,
                                 codingKey: ResetPasswordForm.CodingKeys.passwordConfirmation)
    }
}

extension ResetPasswordViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

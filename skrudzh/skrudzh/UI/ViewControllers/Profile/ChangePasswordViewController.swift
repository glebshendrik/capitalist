//
//  ChangePasswordViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 06/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit
import StaticTableViewController
import SwiftMessages

class ChangePasswordViewController : StaticTableViewController {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordConfirmationTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var viewModel: ChangePasswordViewModel!
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
    
    @IBAction func didTapChangePasswordButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        changePasswordButton.isEnabled = false
        
        firstly {
            viewModel.changePasswordWith(oldPassword: oldPasswordTextField.text?.trimmed,
                                         newPassword: newPasswordTextField.text?.trimmed,
                                         newPasswordConfirmation: newPasswordConfirmationTextField.text?.trimmed)
        }.done {
            self.messagePresenterManager.show(navBarMessage: "Пароль успешно изменен", theme: .success)
            self.navigationController?.popViewController(animated: true)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Невозможно изменить пароль", theme: .error)
            self.validateUI()
        }.finally {
                self.setActivityIndicator(hidden: true)
                self.changePasswordButton.isEnabled = true
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

extension ChangePasswordViewController : FieldsViewControllerProtocol {
    
    var fieldsViewModel: FieldsViewModel {
        return viewModel
    }
    
    func registerFields() {
        fieldsViewModel.register(oldPasswordTextField,
                                 attributeName: ChangePasswordForm.CodingKeys.oldPassword.stringValue,
                                 codingKey: ChangePasswordForm.CodingKeys.oldPassword)
        fieldsViewModel.register(newPasswordTextField,
                                 attributeName: "password",
                                 codingKey: ChangePasswordForm.CodingKeys.newPassword)
        fieldsViewModel.register(newPasswordConfirmationTextField,
                                 attributeName: "password_confirmation",
                                 codingKey: ChangePasswordForm.CodingKeys.newPasswordConfirmation)
    }
}

extension ChangePasswordViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

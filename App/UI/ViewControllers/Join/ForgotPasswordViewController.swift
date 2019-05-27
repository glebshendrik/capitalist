//
//  ForgotPasswordViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import StaticTableViewController
import SwiftMessages

protocol ForgotPasswordOutputProtocol {
    var email: String? { get }
}

class ForgotPasswordViewController : StaticTableViewController, ForgotPasswordOutputProtocol {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var createPasswordResetCodeButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var viewModel: ForgotPasswordViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var email: String? {
        return emailTextField.text?.trimmed
    }
    
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
    
    @IBAction func didTapCreatePasswordResetCodeButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        createPasswordResetCodeButton.isEnabled = false
        
        firstly {
            viewModel.createPasswordResetCodeWith(email: email)
        }.done {
            self.showResetPasswordScreen()
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при создании кода восстановления пароля", theme: .error)
            self.validateUI()
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.createPasswordResetCodeButton.isEnabled = true
        }
    }
    
    @IBAction func didChangeText(_ sender: UITextField) {
        didChangeEditing(sender)
    }
    
    func showResetPasswordScreen() {
        self.messagePresenterManager.show(navBarMessage: "Мы отправили код для смены пароля на ваш Email", theme: .success)
        performSegue(withIdentifier: "ShowResetPasswordScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ResetPasswordInputProtocol,
            segue.identifier == "ShowResetPasswordScreen" {
            destination.set(email: email)
        }
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        set(cells: activityIndicatorCell, hidden: hidden)
        reloadData(animated: animated)
    }
}

extension ForgotPasswordViewController : FieldsViewControllerProtocol {
    
    var fieldsViewModel: FieldsViewModel {
        return viewModel
    }
    
    func registerFields() {
        fieldsViewModel.register(emailTextField,
                                 attributeName: PasswordResetCodeForm.CodingKeys.email.stringValue,
                                 codingKey: PasswordResetCodeForm.CodingKeys.email)
    }
}

extension ForgotPasswordViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}
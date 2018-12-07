//
//  ProfileEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import TPKeyboardAvoiding
import PromiseKit
import StaticDataTableViewController
import SwiftMessages


protocol ProfileEditInputProtocol {
    func set(user: User?)
}

class ProfileEditViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol, ProfileEditInputProtocol {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: ProfileEditViewModel!
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    func set(user: User?) {
        viewModel.set(user: user)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        firstly {
            viewModel.updateProfileWith(firstname: firstnameTextField.text?.trimmed)
        }.done {
            self.messagePresenterManager.show(navBarMessage: "Данные профиля успешно сохранены", theme: .success)
            self.close()
        }.catch { error in
            switch error {
            case ProfileEditError.validation(let validationResults):
                self.show(validationResults: validationResults)
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Невозможно изменить данные профиля", theme: .error)
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func updateUI() {
        firstnameTextField.text = viewModel.firstname
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func show(validationResults: [UserUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = validationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func validationMessageFor(key: UserUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.firstname, _):
            return "Некорректное имя"
        }
    }
}

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

class ProfileEditViewController : StaticDataTableViewController, ProfileEditInputProtocol {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: ProfileEditViewModel!
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        registerFields()
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
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Невозможно изменить данные профиля", theme: .error)
            self.validateUI()
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    @IBAction func didChangeText(_ sender: UITextField) {
        didChangeEditing(sender)
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
}

extension ProfileEditViewController : FieldsViewControllerProtocol {
    
    var fieldsViewModel: FieldsViewModel {
        return viewModel
    }
    
    func registerFields() {
        fieldsViewModel.register(firstnameTextField,
                                 attributeName: UserUpdatingForm.CodingKeys.firstname.stringValue,
                                 codingKey: UserUpdatingForm.CodingKeys.firstname)
    }
}

extension ProfileEditViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

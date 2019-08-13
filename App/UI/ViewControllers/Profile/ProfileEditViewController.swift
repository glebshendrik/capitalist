//
//  ProfileEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class ProfileEditViewController : FormNavBarButtonsEditViewController {    
    var viewModel: ProfileEditViewModel!
    var tableController: ProfileEditTableController!
    
    override var formTitle: String { return "Редактирование профиля" }
    override var saveErrorMessage: String { return "Невозможно изменить данные профиля" }
        
    override func registerFormFields() -> [String : FormField] {
        return [UserUpdatingForm.CodingKeys.firstname.rawValue : tableController.nameField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ProfileEditTableController
        self.tableController.delegate = self
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func didSave() {
        super.didSave()
        messagePresenterManager.show(navBarMessage: "Данные профиля успешно сохранены", theme: .success)
    }
    
    override func updateUI() {
        tableController.nameField.text = viewModel.name
    }
    
    func set(user: User?) {
        viewModel.set(user: user)
    }
}

extension ProfileEditViewController : ProfileEditTableControllerDelegate {
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didTapSave() {
        save()
    }
}

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
    
    override var formTitle: String { return NSLocalizedString("Редактирование профиля", comment: "Редактирование профиля") }
    override var saveErrorMessage: String { return NSLocalizedString("Невозможно изменить данные профиля", comment: "Невозможно изменить данные профиля") }
        
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
        messagePresenterManager.show(navBarMessage: NSLocalizedString("Данные профиля успешно сохранены", comment: "Данные профиля успешно сохранены"), theme: .success)
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

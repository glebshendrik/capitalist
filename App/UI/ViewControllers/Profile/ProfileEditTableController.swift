//
//  ProfileEditTableController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ProfileEditTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didChange(name: String?)
}

class ProfileEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var nameField: FormTextField!
    
    weak var delegate: ProfileEditTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
    }
    
    private func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = NSLocalizedString("Имя", comment: "Имя")
        nameField.imageName = "name-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
}

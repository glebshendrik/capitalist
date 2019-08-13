//
//  ProfileEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ProfileEditTableControllerDelegate {
    func didChange(name: String?)
    func didTapSave()
}

class ProfileEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var nameField: FormTextField!
    
    var delegate: ProfileEditTableControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
    }
    
    private func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = "Имя"
        nameField.imageName = "name-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    override func didTapSave() {
        delegate?.didTapSave()
    }
}

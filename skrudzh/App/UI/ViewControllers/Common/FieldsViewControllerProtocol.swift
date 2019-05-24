//
//  FieldsViewControllerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol FieldsViewControllerProtocol : UIMessagePresenterManagerDependantProtocol {
    
    var fieldsViewModel: FieldsViewModel { get }
    func registerFields()
}

extension FieldsViewControllerProtocol {
    typealias FieldSettings = (background: UIColor, border: UIColor, borderWidth: CGFloat)
    
    func validateUI() {
        fieldsViewModel.fieldViewModels.forEach { fieldViewModel in
            if let textField = fieldViewModel.field as? UITextField {
                set(textField: textField, valid: fieldViewModel.valid)
            }
        }
    }
    
    func set(textField: UITextField, valid: Bool) {
        let settings = valid ? validSettings() : invalidSettings()
        
        textField.superview?.backgroundColor = settings.background
        textField.superview?.borderColor = settings.border
        textField.superview?.borderWidth = settings.borderWidth
    }
    
    func validSettings() -> FieldSettings {
        return (background: UIColor(red: 0.95, green: 0.96, blue: 1, alpha: 1),
                border: UIColor.clear,
                borderWidth: 0)
    }
    
    func invalidSettings() -> FieldSettings {
        return (background: UIColor(red: 1, green: 0.98, blue: 0.98, alpha: 1),
                border: UIColor(red: 1, green: 0.22, blue: 0.27, alpha: 1),
                borderWidth: 1)
    }
    
    func show(errors: [String]) {
        for error in errors {
            messagePresenterManager.show(validationMessage: error)
        }
    }
}

extension FieldsViewControllerProtocol {    
    func didChangeEditing(_ textField: UITextField) {
        if let fieldViewModel = fieldsViewModel.fieldViewModelBy(field: textField) {
            fieldViewModel.removeErrors()
            set(textField: textField, valid: fieldViewModel.valid)
        }
    }
    
    func didBeginEditing(_ textField: UITextField) {
        if let fieldViewModel = fieldsViewModel.fieldViewModelBy(field: textField) {
            show(errors: fieldViewModel.errors)
        }
    }
}

//
//  ReminderEditTableViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ReminderEditTableViewControllerDelegate {
    func didTapStartDate()
    func didTapRecurrence()
    func didChange(message: String?)
    func didTapRemoveButton()
}

class ReminderEditTableViewController : FormFieldsTableViewController {
    @IBOutlet weak var reminderDateField: FormTapField!
    @IBOutlet weak var recurrenceRuleField: FormTapField!
    @IBOutlet weak var reminderMessageField: FormTextField!
    
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: ReminderEditTableViewControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupReminderMessageField()
        setupReminderDateField()
        setupRecurrenceRuleField()
    }
    
    func setupReminderMessageField() {
        reminderMessageField.placeholder = NSLocalizedString("Сообщение", comment: "Сообщение")
        reminderMessageField.imageName = "type-icon"
        reminderMessageField.didChange { [weak self] text in
            self?.delegate?.didChange(message: text)
        }
    }
    
    func setupReminderDateField() {
        reminderDateField.placeholder = NSLocalizedString("Дата", comment: "Дата")
        reminderDateField.imageName = "reminder-date-icon"
        reminderDateField.didTap { [weak self] in
            self?.delegate?.didTapStartDate()
        }
    }
    
    func setupRecurrenceRuleField() {
        recurrenceRuleField.placeholder = NSLocalizedString("Повторяемость", comment: "Повторяемость")
        recurrenceRuleField.imageName = "reminder-recurrence-icon"
        recurrenceRuleField.didTap { [weak self] in
            self?.delegate?.didTapRecurrence()
        }
    }
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        delegate?.didTapRemoveButton()
    }
}

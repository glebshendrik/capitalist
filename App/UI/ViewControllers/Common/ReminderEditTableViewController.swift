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
    @IBOutlet weak var reminderRecurrenceCell: UITableViewCell!
    @IBOutlet weak var reminderDateCell: UITableViewCell!
    
    var delegate: ReminderEditTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderMessageField.didChange { [weak self] text in
            self?.delegate?.didChange(message: text)
        }
        reminderDateField.didTap { [weak self] in
            self?.delegate?.didTapStartDate()
        }
        recurrenceRuleField.didTap { [weak self] in
            self?.delegate?.didTapRecurrence()
        }
    }
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        delegate?.didTapRemoveButton()
    }
}

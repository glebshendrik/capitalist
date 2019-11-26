//
//  ReminderInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ReminderInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapReminderButton(field: ReminderInfoField?)
}

class ReminderInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nextOccurenceLabel: UILabel!
    @IBOutlet weak var recurrenceLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var reminderDelegate: ReminderInfoTableViewCellDelegate? {
        return delegate as? ReminderInfoTableViewCellDelegate
    }

    var reminderField: ReminderInfoField? {
        return field as? ReminderInfoField
    }
        
    override func updateUI() {
        nextOccurenceLabel.text = reminderField?.nextOccurence
        recurrenceLabel.text = reminderField?.recurrence
        messageLabel.text = reminderField?.reminderMessage
        button.setTitle(reminderField?.reminderButtonText, for: .normal)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        reminderDelegate?.didTapReminderButton(field: reminderField)
    }
}


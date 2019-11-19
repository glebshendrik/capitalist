//
//  ReminderInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ReminderInfoTableViewCellDelegate {
    func didTapReminderButton(field: ReminderInfoField?)
}

class ReminderInfoTableViewCell : UITableViewCell {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nextOccurenceLabel: UILabel!
    @IBOutlet weak var recurrenceLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var delegate: ReminderInfoTableViewCellDelegate?
    
    var field: ReminderInfoField? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {        
        nextOccurenceLabel.text = field?.nextOccurence
        recurrenceLabel.text = field?.recurrence
        messageLabel.text = field?.reminderMessage
        button.setTitle(field?.reminderButtonText, for: .normal)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        delegate?.didTapReminderButton(field: field)
    }
}


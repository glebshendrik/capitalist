//
//  ReminderEditTableViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import StaticDataTableViewController
import SkyFloatingLabelTextField

protocol ReminderEditTableViewControllerDelegate {
    func didTapStartDate()
    func didTapRecurrence()
}

class ReminderEditTableViewController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var reminderDateTextField: FloatingTextField!
    @IBOutlet weak var recurrenceRuleTextField: FloatingTextField!
    @IBOutlet weak var reminderMessageTextField: FloatingTextField!
    
    @IBOutlet weak var reminderRecurrenceCell: UITableViewCell!
    @IBOutlet weak var reminderDateCell: UITableViewCell!
    var delegate: ReminderEditTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        reminderDateTextField.updateAppearance()
        recurrenceRuleTextField.updateAppearance()
        reminderMessageTextField.updateAppearance()
    }
        
    @IBAction func didChangeReminderMessage(_ sender: FloatingTextField) {
        sender.updateAppearance()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: false)
        
        if cell == reminderDateCell {
            delegate?.didTapStartDate()
        }
        
        if cell == reminderRecurrenceCell {
            delegate?.didTapRecurrence()
        }
    }
}

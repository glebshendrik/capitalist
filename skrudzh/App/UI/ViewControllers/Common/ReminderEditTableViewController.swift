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
    func didTapRemoveButton()
}

class ReminderEditTableViewController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var reminderDateTextField: FloatingTextField!
    @IBOutlet weak var recurrenceRuleTextField: FloatingTextField!
    @IBOutlet weak var reminderMessageTextField: FloatingTextField!
    
    @IBOutlet weak var removeCell: UITableViewCell!
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
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        delegate?.didTapRemoveButton()
    }
    
    func setRemoveButton(hidden: Bool) {
        set(cell: removeCell, hidden: hidden, animated: false, reload: true)
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

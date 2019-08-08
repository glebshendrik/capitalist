//
//  ReminderEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import RecurrencePicker

protocol ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel)
}

class ReminderEditViewController : FormNavBarButtonsEditViewController {
    
    var viewModel: ReminderViewModel!
    private var delegate: ReminderEditViewControllerDelegate?
    private var tableController: ReminderEditTableViewController!
    
    override var formTitle: String { return "Напоминание" }
    
    func set(reminderViewModel: ReminderViewModel, delegate: ReminderEditViewControllerDelegate?) {
        self.viewModel = reminderViewModel
        self.delegate = delegate
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ReminderEditTableViewController
        self.tableController.delegate = self
    }
    
    override func save() {
        view.endEditing(true)
        viewModel.prepareForSaving()
        delegate?.didSave(reminderViewModel: viewModel)
        close()
    }
    
    override func updateUI() {
        updateStartDateUI()
        updateRecurrenceRuleUI()
        updateMessageUI()
        updateRemoveButtonUI()
    }
}

extension ReminderEditViewController {
    private func updateStartDateUI() {
        tableController.reminderDateField.text = viewModel.startDate
    }
    
    private func updateRecurrenceRuleUI() {
        tableController.recurrenceRuleField.text = viewModel.recurrenceRuleText
    }
    
    private func updateMessageUI() {
        tableController.reminderMessageField.text = viewModel.reminderMessage
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}

extension ReminderEditViewController : ReminderEditTableViewControllerDelegate {
    func didChange(message: String?) {
        viewModel.reminderMessage = message
        updateMessageUI()
    }
    
    func didTapStartDate() {
        present(factory.datePickerViewController(delegate: self,
                                         date: viewModel.reminderStartDate,
                                         minDate: Date(),
                                         maxDate: nil,
                                         mode: .dateAndTime))
    }
    
    func didTapRecurrence() {
        push(factory.recurrencePicker(delegate: self,
                                      recurrenceRule: viewModel.recurrenceRule,
                                      ocurrenceDate: viewModel.reminderStartDate,
                                      language: .russian))
    }
    
    func didTapRemoveButton() {
        viewModel.clear()
        save()
    }
}

extension ReminderEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        viewModel.reminderStartDate = date?.dateBySet(hour: nil, min: nil, secs: 0)
        updateStartDateUI()
    }
}

extension ReminderEditViewController : RecurrencePickerDelegate {
    func recurrencePicker(_ picker: RecurrencePicker, didPickRecurrence recurrenceRule: RecurrenceRule?) {
        viewModel.reminderRecurrenceRule = recurrenceRule?.toRRuleString()
        updateRecurrenceRuleUI()
    }
}

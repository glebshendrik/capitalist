//
//  ReminderEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import RecurrencePicker

protocol ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel)
}

class ReminderEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var viewModel: ReminderViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    private var delegate: ReminderEditViewControllerDelegate?
    private var editTableController: ReminderEditTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.mainNavBarColor        
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    private func save() {
        view.endEditing(true)
        delegate?.didSave(reminderViewModel: viewModel)
        close()
    }
    
    private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTableView",
            let viewController = segue.destination as? ReminderEditTableViewController {
            editTableController = viewController
            viewController.delegate = self
        }
    }
}

extension ReminderEditViewController {
    func set(reminderViewModel: ReminderViewModel, delegate: ReminderEditViewControllerDelegate?) {
        self.viewModel = reminderViewModel
        self.delegate = delegate
    }
    
    private func updateUI() {
        editTableController?.reminderDateTextField?.text = viewModel.startDate
        editTableController?.recurrenceRuleTextField?.text = viewModel.recurrenceRuleText
        editTableController?.reminderMessageTextField?.text = viewModel.reminderMessage
    }
}

extension ReminderEditViewController {
    private func setupUI() {
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "Напоминание"
    }
}

extension ReminderEditViewController : ReminderEditTableViewControllerDelegate {
    func didTapStartDate() {
        let datePickerController = DatePickerViewController()
        datePickerController.set(delegate: self)
        datePickerController.set(date: viewModel.reminderStartDate, minDate: Date(), maxDate: nil, mode: .dateAndTime)        
        datePickerController.modalPresentationStyle = .custom
        present(datePickerController, animated: true, completion: nil)
    }
    
    func didTapRecurrence() {
        let recurrencePicker = RecurrencePicker(recurrenceRule: viewModel.recurrenceRule)
        recurrencePicker.language = .russian
        recurrencePicker.calendar = Calendar.current
        recurrencePicker.tintColor = UIColor(hexString: "6B93FB") ?? .black

        recurrencePicker.occurrenceDate = viewModel.reminderStartDate ?? Date()
        recurrencePicker.delegate = self

        navigationController?.pushViewController(recurrencePicker, animated: true)
    }
}

extension ReminderEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        viewModel.reminderStartDate = date
        updateUI()
    }
}

extension ReminderEditViewController : RecurrencePickerDelegate {
    func recurrencePicker(_ picker: RecurrencePicker, didPickRecurrence recurrenceRule: RecurrenceRule?) {
        viewModel.reminderRecurrenceRule = recurrenceRule?.toRRuleString()
        updateUI()
    }
}

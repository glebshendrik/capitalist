//
//  DatePeriodSelectionViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 29.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol DatePeriodSelectionViewControllerDelegate : class {
    func didSelect(period: DateRangeTransactionFilter?)
}

class DatePeriodSelectionViewController : FormEditViewController {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    var viewModel: DatePeriodSelectionViewModel!
    var tableController: DatePeriodSelectionTableController!
    weak var delegate: DatePeriodSelectionViewControllerDelegate?
    
    lazy var fromDateSelectionHandler = {
        return FromDateSelectionHandler(delegate: self)
    }()
    
    lazy var toDateSelectionHandler = {
        return ToDateSelectionHandler(delegate: self)
    }()
    
    override var shouldLoadData: Bool { return false }
    override var formTitle: String { return NSLocalizedString("Выбор периода", comment: "Выбор периода") }
    
//    override func registerFormFields() -> [String : FormField] {
//        return [CreditCreationForm.CodingKeys.name.rawValue : tableController.nameField,
//                CreditCreationForm.CodingKeys.creditTypeId.rawValue : tableController.creditTypeField,
//                CreditCreationForm.CodingKeys.currency.rawValue : tableController.currencyField,
//                CreditCreationForm.CodingKeys.amountCents.rawValue : tableController.amountField,
//                CreditingTransactionNestedAttributes.CodingKeys.destinationId.rawValue : tableController.expenseSourceField,
//                CreditCreationForm.CodingKeys.returnAmountCents.rawValue : tableController.returnAmountField,
//                CreditCreationForm.CodingKeys.alreadyPaidCents.rawValue : tableController.alreadyPaidField,
//                CreditCreationForm.CodingKeys.monthlyPaymentCents.rawValue : tableController.monthlyPaymentField,
//                CreditCreationForm.CodingKeys.gotAt.rawValue : tableController.gotAtField,
//                CreditCreationForm.CodingKeys.period.rawValue : tableController.periodField]
//    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? DatePeriodSelectionTableController
        self.tableController.delegate = self
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        if viewModel.filterChanged {
            delegate?.didSelect(period: viewModel.selectedDateRangeFilter)
        }        
        close()
    }
    
    @IBAction func didTapResetButton(_ sender: Any) {
        viewModel.reset()
        updateUI()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
        
    override func updateUI() {
        updatePeriodUI()
        updateCustomPeriodUI()
        updateFromUI()
        updateToUI()
        tableController.reloadData(animated: false)
    }
}

extension DatePeriodSelectionViewController {
    func set(delegate: DatePeriodSelectionViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?, transactionsMinDate: Date?, transactionsMaxDate: Date?) {
        viewModel.set(dateRangeFilter: dateRangeFilter,
                      transactionsMinDate: transactionsMinDate,
                      transactionsMaxDate: transactionsMaxDate)
    }
}

extension DatePeriodSelectionViewController : DatePeriodSelectionTableControllerDelegate {
    func didTapPeriod() {
        showPeriodsSheet()
    }
    
    func didChange(useCustomPeriod: Bool) {
        update(useCustomPeriod: useCustomPeriod)
    }
    
    func didTapFrom() {
        showDatePicker(date: viewModel.fromDate,
                       minDate: nil,
                       maxDate: viewModel.fromDateMaxDate,
                       delegate: fromDateSelectionHandler)
    }
    
    func didTapTo() {
        showDatePicker(date: viewModel.toDate,
                       minDate: viewModel.toDateMinDate,
                       maxDate: nil,
                       delegate: toDateSelectionHandler)
    }
}

extension DatePeriodSelectionViewController {
    private func showPeriodsSheet() {
        let actions = viewModel.datePeriods.map { datePeriod in
            return UIAlertAction(title: datePeriod.title,
                                 style: .default,
                                 handler: { _ in
                                    self.update(datePeriod: datePeriod)
            })
        }
        
        sheet(title: nil, actions: actions)
    }
    
    private func showDatePicker(date: Date?, minDate: Date?, maxDate: Date?, delegate: DatePickerViewControllerDelegate) {
        let datePickerController = DatePickerViewController()
        datePickerController.set(delegate: delegate)
        datePickerController.set(date: date, minDate: minDate, maxDate: maxDate)
        datePickerController.modalPresentationStyle = .custom
        present(datePickerController, animated: true, completion: nil)        
    }
}

extension DatePeriodSelectionViewController {
    func update(datePeriod: DatePeriod) {
        viewModel.set(datePeriod: datePeriod)
        updateUI()
    }
    
    func update(useCustomPeriod: Bool) {
        viewModel.set(useCustomPeriod: useCustomPeriod)
        updateUI()
    }
    
    func update(from: Date) {
        viewModel.set(fromDate: from)
        updateUI()
    }
    
    func update(to: Date) {
        viewModel.set(toDate: to)
        updateUI()
    }
}

extension DatePeriodSelectionViewController {
    func updatePeriodUI() {
        tableController.periodField.text = viewModel.selectedDatePeriod.title
    }
    
    func updateCustomPeriodUI() {
        tableController.useCustomPeriodField.value = viewModel.useCustomDatesSwitchOn
    }
    
    func updateFromUI() {
        tableController.fromField.text = viewModel.fromDateFormatted
    }
    
    func updateToUI() {
        tableController.toField.text = viewModel.toDateFormatted
    }
}

protocol FromDateSelectionHandlerDelegate : class {
    func didSelectFromDate(date: Date?)
}

protocol ToDateSelectionHandlerDelegate : class {
    func didSelectToDate(date: Date?)
}

extension DatePeriodSelectionViewController : FromDateSelectionHandlerDelegate, ToDateSelectionHandlerDelegate {
    
    class FromDateSelectionHandler : DatePickerViewControllerDelegate {
        weak var delegate: FromDateSelectionHandlerDelegate? = nil
        
        init(delegate: FromDateSelectionHandlerDelegate) {
            self.delegate = delegate
        }
        
        func didSelect(date: Date?) {
            delegate?.didSelectFromDate(date: date)
        }
    }
    
    class ToDateSelectionHandler : DatePickerViewControllerDelegate {
        weak var delegate: ToDateSelectionHandlerDelegate? = nil
        
        init(delegate: ToDateSelectionHandlerDelegate) {
            self.delegate = delegate
        }
        
        func didSelect(date: Date?) {
            delegate?.didSelectToDate(date: date)
        }
    }
    
    func didSelectFromDate(date: Date?) {
        guard let date = date else { return }
        update(from: date)
    }
    
    func didSelectToDate(date: Date?) {
        guard let date = date else { return }
        update(to: date)
    }
}

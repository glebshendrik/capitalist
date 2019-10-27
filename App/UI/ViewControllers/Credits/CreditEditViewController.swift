//
//  CreditEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol CreditEditViewControllerDelegate {
    func didCreateCredit()
    func didUpdateCredit()
    func didRemoveCredit()
}

class CreditEditViewController : FormTransactionsDependableEditViewController {
    var viewModel: CreditEditViewModel!
    var tableController: CreditEditTableController!
    var delegate: CreditEditViewControllerDelegate?
    
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return viewModel.title }
    override var saveErrorMessage: String { return "Ошибка при сохранении" }
    override var removeErrorMessage: String { return "Ошибка при удалении" }
    override var removeQuestionMessage: String { return "Удалить кредит?" }
    
    override func registerFormFields() -> [String : FormField] {
        return [CreditCreationForm.CodingKeys.name.rawValue : tableController.nameField,
                CreditCreationForm.CodingKeys.creditTypeId.rawValue : tableController.creditTypeField,
                CreditCreationForm.CodingKeys.currency.rawValue : tableController.currencyField,
                CreditCreationForm.CodingKeys.amountCents.rawValue : tableController.amountField,
                CreditCreationForm.CodingKeys.alreadyPaidCents.rawValue : tableController.alreadyPaidField,
                CreditCreationForm.CodingKeys.monthlyPaymentCents.rawValue : tableController.monthlyPaymentField,
                CreditCreationForm.CodingKeys.gotAt.rawValue : tableController.gotAtField,
                CreditCreationForm.CodingKeys.period.rawValue : tableController.periodField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? CreditEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeCredit(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        super.didSave()
        viewModel.isNew ? delegate?.didCreateCredit() : delegate?.didUpdateCredit()
    }
    
    override func didRemove() {
        delegate?.didRemoveCredit()
    }
    
    override func updateUI() {
        updateIconUI()
        updateCreditTypeUI()
        updateTextFieldsUI()
        updateCurrencyUI()
        updateGotAtUI()
        updatePeriodUI()
        updateReminderUI()
        updateRemoveButtonUI()
        updateTableUI(animated: false)
    }
}

extension CreditEditViewController {
    func set(delegate: CreditEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(creditId: Int) {
        viewModel.set(creditId: creditId)
    }
}

extension CreditEditViewController : CreditEditTableControllerDelegate {
    func didTapIcon() {
        push(factory.iconsViewController(delegate: self, iconCategory: IconCategory.expenseSourceDebt))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didTapCreditType() {
        guard viewModel.canChangeCreditType else { return }
        showCreditTypesSheet()
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        push(factory.currenciesViewController(delegate: self))
    }
    
    func didChange(amount: String?) {
        viewModel.amount = amount
    }
    
    func didChange(alreadyPaid: String?) {
        viewModel.alreadyPaid = alreadyPaid
    }
    
    func didChange(monthlyPayment: String?) {
        viewModel.monthlyPayment = monthlyPayment
    }

    func didTapGotAt() {
        modal(factory.datePickerViewController(delegate: self,
                                               date: viewModel.gotAt,
                                               minDate: nil,
                                               maxDate: Date(),
                                               mode: .date), animated: true)
    }
    
    func didChange(period: Int?) {
        viewModel.period = period
    }
    
    func didTapSetReminder() {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminderViewModel))
    }
}

extension CreditEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        update(iconURL: icon.url)
    }
}

extension CreditEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
}

extension CreditEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        update(gotAt: date)
    }
}

extension CreditEditViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        update(reminder: reminderViewModel)
    }
}

extension CreditEditViewController {
    func update(iconURL: URL) {
        viewModel.selectedIconURL = iconURL
        updateIconUI()
    }
    
    func update(creditType: CreditTypeViewModel) {
        viewModel.selectedCreditType = creditType
        updateCreditTypeUI()
        updateTextFieldsUI()
        updatePeriodUI()
        updateTableUI()
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
    
    func update(gotAt: Date?) {
        viewModel.gotAt = gotAt ?? Date()
        updateGotAtUI()
    }
    
    func update(reminder: ReminderViewModel) {
        viewModel.reminderViewModel = reminder
        updateReminderUI()
    }
}

extension CreditEditViewController {
    func updateIconUI() {
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.iconDefaultImageName, renderingMode: .alwaysTemplate)
        tableController.iconView.tintColor = UIColor.by(.textFFFFFF)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.text = viewModel.name
        
        tableController.amountField.text = viewModel.amount
        tableController.amountField.currency = viewModel.selectedCurrency
        
        tableController.alreadyPaidField.text = viewModel.alreadyPaid
        tableController.alreadyPaidField.isEnabled = viewModel.canChangeAlreadyPaid
        tableController.alreadyPaidField.currency = viewModel.selectedCurrency
        
        tableController.monthlyPaymentField.text = viewModel.monthlyPayment
        tableController.monthlyPaymentField.currency = viewModel.selectedCurrency
    }
    
    func updateGotAtUI() {
        tableController.gotAtField.text = viewModel.gotAtFormatted
    }
    
    func updateCreditTypeUI() {
        tableController.creditTypeField.text = viewModel.selectedCreditType?.name
        tableController.creditTypeField.isEnabled = viewModel.canChangeCreditType
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrency?.name
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        
        tableController.amountField.currency = viewModel.selectedCurrency
        tableController.alreadyPaidField.currency = viewModel.selectedCurrency
        tableController.monthlyPaymentField.currency = viewModel.selectedCurrency
    }
    
    func updatePeriodUI() {
        tableController.periodField.minimumValue = viewModel.minValue
        tableController.periodField.maximumValue = viewModel.maxValue
        tableController.periodField.value = viewModel.periodValue
        tableController.periodField.valueFormatter = { [weak self] value in
            return self?.viewModel.selectedCreditType?.formatted(value: Int(value)) ?? "\(value)"
        }
    }
    
    func updateReminderUI() {
        tableController.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        tableController.reminderLabel.text = viewModel.reminder
    }
        
    func updateRemoveButtonUI(reload: Bool = false, animated: Bool = false) {
        tableController.removeButton.setTitle("Удалить кредит", for: .normal)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: animated, reload: reload)
    }
    
    func updateTableUI(animated: Bool = true) {
        tableController.set(cell: tableController.monthlyPaymentCell, hidden: viewModel.monthlyPaymentFieldHidden, animated: false, reload: false)
        tableController.set(cell: tableController.periodCell, hidden: viewModel.periodFieldHidden, animated: false, reload: false)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: false, reload: false)
        tableController.reloadData(animated: animated)
    }
    
    private func showCreditTypesSheet() {
        let actions = viewModel.creditTypes.map { creditType in
            return UIAlertAction(title: creditType.name,
                                 style: .default,
                                 handler: { _ in
                                    self.update(creditType: creditType)
            })
        }
        
        sheet(title: nil, actions: actions)
    }
}
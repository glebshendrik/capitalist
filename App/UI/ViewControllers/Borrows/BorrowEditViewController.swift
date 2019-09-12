//
//  BorrowEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol BorrowEditViewControllerDelegate {
    func didCreateDebt()
    func didCreateLoan()
    func didUpdateDebt()
    func didUpdateLoan()
    func didRemoveDebt()
    func didRemoveLoan()
}

class BorrowEditViewController : FormTransactionsDependableEditViewController {
    
    var viewModel: ExpenseCategoryEditViewModel!
    var tableController: BorrowEditTableController!
    var delegate: BorrowEditViewControllerDelegate?
    
    override var shouldLoadData: Bool { return viewModel.isNew }
    override var formTitle: String {
        return viewModel.isNew ? "Новая категория трат" : "Категория трат"
    }
    override var saveErrorMessage: String { return "Ошибка при сохранении категории трат" }
    override var removeErrorMessage: String { return "Ошибка при удалении категории трат" }
    override var removeQuestionMessage: String { return "Удалить категорию трат?" }
    
    override func registerFormFields() -> [String : FormField] {
        return [ExpenseCategory.CodingKeys.name.rawValue : tableController.nameField,
                ExpenseCategory.CodingKeys.monthlyPlannedCurrency.rawValue : tableController.currencyField,
                ExpenseCategory.CodingKeys.incomeSourceCurrency.rawValue : tableController.incomeSourceCurrencyField,
                ExpenseCategory.CodingKeys.monthlyPlannedCents.rawValue : tableController.monthlyPlannedField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? BorrowEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadDefaultCurrency()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeExpenseCategory(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        super.didSave()
        if viewModel.isNew {
            delegate?.didCreateExpenseCategory(with: viewModel.basketType, name: viewModel.name!)
        }
        else {
            delegate?.didUpdateExpenseCategory(with: viewModel.basketType)
        }
    }
    
    override func didRemove() {
        delegate?.didRemoveExpenseCategory(with: viewModel.basketType)
    }
    
    override func updateUI() {
        updateIconUI()
        updateTextFieldsUI()
        updateCurrencyUI()
        updateIncomeSourceCurrencyUI()
        updateReminderUI()
        updateRemoveButtonUI()
    }
}

extension ExpenseCategoryEditViewController {
    func set(delegate: ExpenseCategoryEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseCategory: ExpenseCategory) {
        viewModel.set(expenseCategory: expenseCategory)
    }
    
    func set(basketType: BasketType) {
        viewModel.set(basketType: basketType)
    }
}

extension ExpenseCategoryEditViewController : ExpenseCategoryEditTableControllerDelegate {
    func didTapIcon() {
        push(factory.iconsViewController(delegate: self, iconCategory: viewModel.basketType.iconCategory))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(monthlyPlanned: String?) {
        viewModel.monthlyPlanned = monthlyPlanned
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        let delegate =  ExpenseCategoryCurrencyDelegate(delegate: self)
        push(factory.currenciesViewController(delegate: delegate))
    }
    
    func didTapIncomeSourceCurrency() {
        guard viewModel.canChangeIncomeSourceCurrency else { return }
        let delegate =  IncomeSourceDependantCurrencyDelegate(delegate: self)
        push(factory.currenciesViewController(delegate: delegate))
    }
    
    func didTapSetReminder() {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminderViewModel))
    }
}

extension ExpenseCategoryEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
}

extension ExpenseCategoryEditViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminderViewModel = reminderViewModel
        updateReminderUI()
    }
}

class IncomeSourceDependantCurrencyDelegate : CurrenciesViewControllerDelegate {
    let delegate: ExpenseCategoryEditViewController?
    
    init(delegate: ExpenseCategoryEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelectCurrency(currency: Currency) {
        delegate?.update(incomeSourceCurrency: currency)
    }
}

class ExpenseCategoryCurrencyDelegate : CurrenciesViewControllerDelegate {
    let delegate: ExpenseCategoryEditViewController?
    
    init(delegate: ExpenseCategoryEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelectCurrency(currency: Currency) {
        delegate?.update(currency: currency)
    }
}

extension ExpenseCategoryEditViewController {
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
    
    func update(incomeSourceCurrency: Currency) {
        viewModel.selectedIncomeSourceCurrency = incomeSourceCurrency
        updateIncomeSourceCurrencyUI()
    }
}

extension ExpenseCategoryEditViewController {
    func updateIconUI() {
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        tableController.iconView.tintColor = UIColor.by(.textFFFFFF)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.text = viewModel.name
        tableController.monthlyPlannedField.text = viewModel.monthlyPlanned
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrencyName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        tableController.monthlyPlannedField.currency = viewModel.selectedCurrency
    }
    
    func updateIncomeSourceCurrencyUI() {
        tableController.incomeSourceCurrencyField.text = viewModel.selectedIncomeSourceCurrencyName
        tableController.incomeSourceCurrencyField.isEnabled = viewModel.canChangeIncomeSourceCurrency
        tableController.set(cell: tableController.incomeSourceCurrencyCell, hidden: !viewModel.canChangeIncomeSourceCurrency)
    }
    
    func updateReminderUI() {
        tableController.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        tableController.reminderLabel.text = viewModel.reminder
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}



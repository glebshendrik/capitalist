//
//  BorrowEditViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol BorrowEditViewControllerDelegate : class {
    func didCreateDebt()
    func didCreateLoan()
    func didUpdateDebt()
    func didUpdateLoan()
    func didRemoveDebt()
    func didRemoveLoan()
}

class BorrowEditViewController : FormTransactionsDependableEditViewController {
    var viewModel: BorrowEditViewModel!
    var tableController: BorrowEditTableController!
    weak var delegate: BorrowEditViewControllerDelegate?
    
    lazy var borrowedAtDateSelectionDelegate = {
        return BorrowedAtDateSelectionDelegate(delegate: self)
    }()
    
    lazy var paydayDateSelectionDelegate = {
        return PaydayDateSelectionDelegate(delegate: self)
    }()
        
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return viewModel.title }
    override var saveErrorMessage: String { return NSLocalizedString("Ошибка при сохранении", comment: "Ошибка при сохранении") }
    override var removeErrorMessage: String { return NSLocalizedString("Ошибка при удалении", comment: "Ошибка при удалении") }
    override var removeQuestionMessage: String { return viewModel.removeQuestion }
    
    override func registerFormFields() -> [String : FormField] {
        return [BorrowCreationForm.CodingKeys.name.rawValue : tableController.nameField,
                BorrowCreationForm.CodingKeys.amountCurrency.rawValue : tableController.currencyField,
                "amount" : tableController.amountField,
                BorrowCreationForm.CodingKeys.borrowedAt.rawValue : tableController.borrowedAtField,
                BorrowCreationForm.CodingKeys.payday.rawValue : tableController.paydayField,
                BorrowingTransactionNestedAttributes.CodingKeys.destinationId.rawValue : tableController.expenseSourceField,
                BorrowingTransactionNestedAttributes.CodingKeys.sourceId.rawValue : tableController.expenseSourceField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? BorrowEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeBorrow(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        super.didSave()
        guard let type = viewModel.type else { return }
        if type == .debt {
            viewModel.isNew ? delegate?.didCreateDebt() : delegate?.didUpdateDebt()
        }
        else {
            viewModel.isNew ? delegate?.didCreateLoan() : delegate?.didUpdateLoan()
        }
    }
    
    override func didRemove() {
        guard let type = viewModel.type else { return }
        type == .debt ? delegate?.didRemoveDebt() : delegate?.didRemoveLoan()
    }
    
    override func updateUI() {
        updateIconUI()
        updateTextFieldsUI()
        updateCurrencyUI()
        updateDatesUI()
        updateInBalanceUI()
        updateExpenseSourceUI()
        updateReturnButtonUI()
        updateRemoveButtonUI(reload: true, animated: true)
        focusFirstEmptyField()
    }
}

extension BorrowEditViewController {
    func set(delegate: BorrowEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(borrowId: Int, type: BorrowType) {
        viewModel.set(borrowId: borrowId, type: type)
    }
    
    func set(type: BorrowType,
             source: TransactionSource?,
             destination: TransactionDestination?,
             borrowingTransaction: Transaction?) {
        viewModel.set(type: type,
                      source: source,
                      destination: destination,
                      borrowingTransaction: borrowingTransaction)
    }
}

extension BorrowEditViewController : BorrowEditTableControllerDelegate {
    func didAppear() {
        focusFirstEmptyField()
    }
    
    func didTapIcon() {
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.common))
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        modal(factory.currenciesViewController(delegate: self))
    }
    
    func didTapBorrowedAt() {
        guard viewModel.canChangeBorrowedAt else { return }
        modal(factory.datePickerViewController(delegate: borrowedAtDateSelectionDelegate,
                                               date: viewModel.borrowedAt,
                                               minDate: nil,
                                               maxDate: Date(),
                                               mode: .date), animated: true)
    }
    
    func didTapPayday() {        
        modal(factory.datePickerViewController(delegate: paydayDateSelectionDelegate,
                                               date: viewModel.payday,
                                               minDate: Date(),
                                               maxDate: nil,
                                               mode: .date), animated: true)
    }
    
    func didTapExpenseSource() {
        guard viewModel.canChangeExpenseSource else { return }
        slideUp(factory.expenseSourceSelectViewController(delegate: self,
                                                          skipExpenseSourceId: nil,
                                                          selectionType: viewModel.expenseSourceSelectionType,
                                                          currency: viewModel.selectedCurrency?.code))
    }
    
    func didTapReturn() {
        showReturnTransactionScreen()
    }
    
    private func showReturnTransactionScreen() {
        modal(factory.transactionEditViewController(delegate: self,
                                                    source: nil,
                                                    destination: nil,
                                                    returningBorrow: viewModel.asReturningBorrow(),
                                                    transactionType: nil))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(amount: String?) {
        viewModel.amount = amount
    }
    
    func didChange(shouldRecordOnBalance: Bool) {
        viewModel.shouldRecordOnBalance = shouldRecordOnBalance
        updateExpenseSourceUI(reload: true, animated: false)
    }
    
    func didChange(comment: String?) {
        viewModel.comment = comment
    }
    
    func didTapSave() {
        save()
    }
}

extension BorrowEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
}

extension BorrowEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
}

class BorrowedAtDateSelectionDelegate : DatePickerViewControllerDelegate {
    weak var delegate: BorrowEditViewController? = nil
    
    init(delegate: BorrowEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelect(date: Date?) {
        delegate?.update(borrowedAt: date)
    }
}

class PaydayDateSelectionDelegate : DatePickerViewControllerDelegate {
    weak var delegate: BorrowEditViewController? = nil
    
    init(delegate: BorrowEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelect(date: Date?) {
        delegate?.update(payday: date)
    }
}

extension BorrowEditViewController : ExpenseSourcesViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(expenseSource: sourceExpenseSourceViewModel)
    }
    
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(expenseSource: destinationExpenseSourceViewModel)
    }
}

extension BorrowEditViewController {
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
        updateExpenseSourceUI(reload: true, animated: true)
    }
    
    func update(borrowedAt: Date?) {
        viewModel.borrowedAt = borrowedAt ?? Date()
        updateDatesUI()
    }
    
    func update(payday: Date?) {
        viewModel.payday = payday
        updateDatesUI()
    }
    
    func update(expenseSource: ExpenseSourceViewModel?) {        
        viewModel.selectedExpenseSource = expenseSource
        updateExpenseSourceUI(reload: true, animated: false)
    }
}

extension BorrowEditViewController {
    func focusFirstEmptyField() {
        if viewModel.name == nil && isCurrentTopmostPresentedViewController {
            tableController.nameField.textField.becomeFirstResponder()
        }
    }
    
    func updateIconUI() {
        tableController.iconView.iconURL = viewModel.selectedIconURL
        tableController.iconView.defaultIconName = viewModel.iconDefaultImageName
        tableController.iconView.iconTintColor = UIColor.by(.white100)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.text = viewModel.name
        tableController.nameField.placeholder = viewModel.nameTitle
        
        tableController.amountField.text = viewModel.amount
        tableController.amountField.placeholder = viewModel.amountTitle
        tableController.amountField.currency = viewModel.selectedCurrency
        tableController.amountField.isEnabled = viewModel.canChangeAmount
        
        tableController.commentView.text = viewModel.comment ?? ""
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrency?.translatedName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        tableController.amountField.currency = viewModel.selectedCurrency
    }
    
    func updateInBalanceUI() {
        tableController.onBalanceSwitchField.placeholder = viewModel.shouldRecordOnBalanceTitle
        tableController.onBalanceSwitchField.value = viewModel.shouldRecordOnBalance
    }
    
    func updateExpenseSourceUI(reload: Bool = false, animated: Bool = false) {
        tableController.set(cell: tableController.onBalanceCell, hidden: viewModel.onBalanceSwitchHidden, animated: false, reload: false)
        tableController.onBalanceSwitchField.value = viewModel.shouldRecordOnBalance
        
        tableController.set(cell: tableController.expenseSourceCell, hidden: viewModel.expenseSourceFieldHidden, animated: false, reload: false)
        tableController.expenseSourceField.placeholder = viewModel.expenseSourceTitle
        tableController.expenseSourceField.text = viewModel.expenseSourceName
        tableController.expenseSourceField.subValue = viewModel.expenseSourceAmount
        tableController.expenseSourceField.imageName = viewModel.expenseSourceIconDefaultImageName
        tableController.expenseSourceField.imageURL = viewModel.expenseSourceIconURL
        tableController.expenseSourceField.isEnabled = viewModel.canChangeExpenseSource
        if reload {
            tableController.reloadData(animated: animated)
        }
    }
    
    func updateDatesUI() {
        tableController.borrowedAtField.text = viewModel.borrowedAtFormatted
        tableController.borrowedAtField.placeholder = viewModel.borrowedAtTitle
        tableController.borrowedAtField.isEnabled = viewModel.canChangeBorrowedAt
        
        tableController.paydayField.text = viewModel.paydayFormatted
        tableController.paydayField.placeholder = NSLocalizedString("Дата возврата", comment: "Дата возврата")
    }
    
    func updateReturnButtonUI(reload: Bool = false, animated: Bool = false) {
        tableController.returnButton.setTitle(viewModel.returnTitle, for: .normal)
        tableController.set(cell: tableController.returnCell, hidden: viewModel.returnButtonHidden, animated: animated, reload: reload)
    }
    
    func updateRemoveButtonUI(reload: Bool = false, animated: Bool = false) {
        tableController.removeButton.setTitle(viewModel.removeTitle, for: .normal)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: animated, reload: reload)
    }
    
    func updateTableUI(animated: Bool = true) {
        tableController.set(cell: tableController.onBalanceCell, hidden: viewModel.onBalanceSwitchHidden, animated: false, reload: false)
        tableController.set(cell: tableController.expenseSourceCell, hidden: viewModel.expenseSourceFieldHidden, animated: false, reload: false)
        tableController.set(cell: tableController.returnCell, hidden: viewModel.returnButtonHidden, animated: false, reload: false)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: false, reload: false)
        tableController.reloadData(animated: animated)
    }

}

extension BorrowEditViewController: TransactionEditViewControllerDelegate {
    var isSelectingTransactionables: Bool {
        return false
    }
    
    func didCreateTransaction(id: Int, type: TransactionType) {
        close {
            guard let type = self.viewModel.type else  { return }
            if type == .debt {
                self.delegate?.didUpdateDebt()
            }
            else {
                self.delegate?.didUpdateLoan()
            }
            
        }
    }

    func didUpdateTransaction(id: Int, type: TransactionType) {

    }

    func didRemoveTransaction(id: Int, type: TransactionType) {

    }
    
    func shouldShowCreditEditScreen(source: IncomeSourceViewModel?,
                                    destination: TransactionDestination,
                                    creditingTransaction: Transaction?) {
        
    }

    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        
    }    
}

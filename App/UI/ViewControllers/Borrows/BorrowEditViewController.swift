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
    var viewModel: BorrowEditViewModel!
    var tableController: BorrowEditTableController!
    var delegate: BorrowEditViewControllerDelegate?
    
    override var shouldLoadData: Bool { return !viewModel.isNew }
    override var formTitle: String { return viewModel.title }
    override var saveErrorMessage: String { return "Ошибка при сохранении" }
    override var removeErrorMessage: String { return "Ошибка при удалении" }
    override var removeQuestionMessage: String { return viewModel.removeQuestion }
    
    override func registerFormFields() -> [String : FormField] {
        return [BorrowCreationForm.CodingKeys.name.rawValue : tableController.nameField,
                BorrowCreationForm.CodingKeys.amountCurrency.rawValue : tableController.currencyField,
                BorrowCreationForm.CodingKeys.amountCents.rawValue : tableController.amountField,
                BorrowCreationForm.CodingKeys.borrowedAt.rawValue : tableController.borrowedAtField,
                BorrowCreationForm.CodingKeys.payday.rawValue : tableController.paydayField,
                BorrowingTransactionNestedAttributes.CodingKeys.expenseSourceToId.rawValue : tableController.expenseSourceField,
                BorrowingTransactionNestedAttributes.CodingKeys.expenseSourceFromId.rawValue : tableController.expenseSourceField]
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
        updateExpenseSourceUI()
        updateReturnButtonUI()
        updateRemoveButtonUI()
        updateTableUI(animated: true)
    }
}

extension BorrowEditViewController {
    func set(delegate: BorrowEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(borrowId: Int, type: BorrowType) {
        viewModel.set(borrowId: borrowId, type: type)
    }
    
    func set(type: BorrowType, expenseSourceFrom: ExpenseSourceViewModel?, expenseSourceTo: ExpenseSourceViewModel?) {
        viewModel.set(type: type, expenseSourceFrom: expenseSourceFrom, expenseSourceTo: expenseSourceTo)
    }
}

extension BorrowEditViewController : BorrowEditTableControllerDelegate {
    func didTapIcon() {
        push(factory.iconsViewController(delegate: self, iconCategory: IconCategory.expenseSourceDebt))
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        push(factory.currenciesViewController(delegate: self))
    }
    
    func didTapBorrowedAt() {
        let delegate = BorrowedAtDateSelectionDelegate(delegate: self)
        modal(factory.datePickerViewController(delegate: delegate,
                                               date: viewModel.borrowedAt,
                                               minDate: nil,
                                               maxDate: Date(),
                                               mode: .dateAndTime), animated: true)
    }
    
    func didTapPayday() {
        let delegate = PaydayDateSelectionDelegate(delegate: self)
        modal(factory.datePickerViewController(delegate: delegate,
                                               date: viewModel.payday,
                                               minDate: Date(),
                                               maxDate: nil,
                                               mode: .date), animated: true)
    }
    
    func didTapExpenseSource() {
        slideUp(viewController:
            factory.expenseSourceSelectViewController(delegate: self,
                                                      skipExpenseSourceId: nil,
                                                      selectionType: viewModel.expenseSourceSelectionType,
                                                      noDebts: true,
                                                      accountType: nil,
                                                      currency: viewModel.selectedCurrency?.code))
    }
    
    func didTapReturn() {
        showReturnTransactionScreen()
    }
    
    private func showReturnTransactionScreen() {
        
        modal(factory.fundsMoveEditViewController(delegate: self,
                                                  startable: nil,
                                                  completable: nil,
                                                  borrow: viewModel.asReturningBorrow()))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(amount: String?) {
        viewModel.amount = amount
    }
    
    func didChange(alreadyOnBalance: Bool) {
        viewModel.onBalance = alreadyOnBalance
        updateExpenseSourceUI()
    }
    
    func didChange(comment: String?) {
        viewModel.comment = comment
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
    let delegate: BorrowEditViewController?
    
    init(delegate: BorrowEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelect(date: Date?) {
        delegate?.update(borrowedAt: date)
    }
}

class PaydayDateSelectionDelegate : DatePickerViewControllerDelegate {
    let delegate: BorrowEditViewController?
    
    init(delegate: BorrowEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelect(date: Date?) {
        delegate?.update(payday: date)
    }
}

extension BorrowEditViewController : ExpenseSourceSelectViewControllerDelegate {
    func didSelect(startableExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(expenseSource: startableExpenseSourceViewModel)
    }
    
    func didSelect(completableExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(expenseSource: completableExpenseSourceViewModel)
    }
}

extension BorrowEditViewController {
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
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
        updateUI()
    }
}

extension BorrowEditViewController {
    func updateIconUI() {
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.iconDefaultImageName, renderingMode: .alwaysTemplate)
        tableController.iconView.tintColor = UIColor.by(.textFFFFFF)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.text = viewModel.name
        tableController.nameField.placeholder = viewModel.nameTitle
        
        tableController.amountField.text = viewModel.amount
        tableController.amountField.placeholder = viewModel.amountTitle
        tableController.amountField.currency = viewModel.selectedCurrency
        
        tableController.commentView.text = viewModel.comment ?? ""
    }
    
    func updateDatesUI() {
        tableController.borrowedAtField.text = viewModel.borrowedAtFormatted
        tableController.borrowedAtField.placeholder = viewModel.borrowedAtTitle
        
        tableController.paydayField.text = viewModel.paydayFormatted
        tableController.paydayField.placeholder = "Дата возврата"
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrency?.name
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        tableController.amountField.currency = viewModel.selectedCurrency
    }
    
    func updateExpenseSourceUI() {
        tableController.set(cell: tableController.onBalanceCell, hidden: viewModel.onBalanceSwitchHidden)
        tableController.onBalanceSwitchField.value = viewModel.onBalance
        
        tableController.set(cell: tableController.expenseSourceCell, hidden: viewModel.expenseSourceFieldHidden)
        tableController.expenseSourceField.placeholder = viewModel.expenseSourceTitle
        tableController.expenseSourceField.text = viewModel.expenseSourceName
        tableController.expenseSourceField.subValue = viewModel.expenseSourceAmount
        tableController.expenseSourceField.imageName = viewModel.expenseSourceIconDefaultImageName
        tableController.expenseSourceField.imageURL = viewModel.expenseSourceIconURL
    }
    
    func updateReturnButtonUI() {
        tableController.returnLabel.text = viewModel.returnTitle
        tableController.set(cell: tableController.returnCell, hidden: viewModel.returnButtonHidden, animated: true)
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
    
    func updateTableUI(animated: Bool = true) {
        tableController.set(cell: tableController.onBalanceCell, hidden: viewModel.onBalanceSwitchHidden, animated: animated, reload: false)
        tableController.set(cell: tableController.expenseSourceCell, hidden: viewModel.expenseSourceFieldHidden, animated: animated, reload: false)
        tableController.set(cell: tableController.returnCell, hidden: viewModel.returnButtonHidden, animated: true, reload: false)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: animated, reload: false)
        tableController.reloadData(animated: animated)
    }

}

extension BorrowEditViewController: FundsMoveEditViewControllerDelegate {
    func didCreateFundsMove() {
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

    func didUpdateFundsMove() {

    }

    func didRemoveFundsMove() {

    }
}

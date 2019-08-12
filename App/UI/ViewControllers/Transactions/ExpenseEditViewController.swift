//
//  ExpenseEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExpenseEditViewControllerDelegate {
    func didCreateExpense()
    func didUpdateExpense()
    func didRemoveExpense()
}

class ExpenseEditViewController : TransactionEditViewController {
    
    var expenseEditViewModel: ExpenseEditViewModel!
    
    private var delegate: ExpenseEditViewControllerDelegate? = nil
    
    override var viewModel: TransactionEditViewModel! {
        return expenseEditViewModel
    }
    
    override func registerFormFields() -> [String : FormField] {
        return [Expense.CodingKeys.expenseSourceId.rawValue : tableController.sourceField,
                Expense.CodingKeys.expenseCategoryId.rawValue : tableController.destinationField,
                Expense.CodingKeys.amountCents.rawValue: tableController.amountField,
                Expense.CodingKeys.convertedAmountCents.rawValue: tableController.exchangeField]
    }
    
    func set(delegate: ExpenseEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseId: Int) {
        expenseEditViewModel.set(expenseId: expenseId)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseCategoryViewModel) {
        expenseEditViewModel.set(startable: startable, completable: completable)
    }
    
    override func savePromise() -> Promise<Void> {
        return expenseEditViewModel.save()
    }
    
    override func didSave() {
        super.didSave()
        if self.viewModel.isNew {
            self.delegate?.didCreateExpense()
        }
        else {
            self.delegate?.didUpdateExpense()
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return expenseEditViewModel.removeExpense()
    }
    
    override func didRemove() {
        self.delegate?.didRemoveExpense()
    }

    override func didTapSource() {
        slideUp(viewController: factory.expenseSourceSelectViewController(delegate: self, skipExpenseSourceId: nil, selectionType: .startable))
    }
    
    override func didTapDestination() {
        slideUp(viewController: factory.expenseCategorySelectViewController(delegate: self))
    }
}

extension ExpenseEditViewController {
    override func didChange(includedInBalance: Bool) {
        expenseEditViewModel.includedInBalance = includedInBalance
        updateInBalanceUI()
    }
    
    override func updateInBalanceUI() {
        tableController.set(cell: tableController.inBalanceCell, hidden: !expenseEditViewModel.ableToIncludeInBalance)
        tableController.inBalanceSwitchField.value = expenseEditViewModel.includedInBalance
    }
}

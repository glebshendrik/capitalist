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

protocol ExpenseEditInputProtocol {
    func set(delegate: ExpenseEditViewControllerDelegate?)
    func set(expenseId: Int)
    func set(startable: ExpenseSourceViewModel, completable: ExpenseCategoryViewModel)
}

class ExpenseEditViewController : TransactionEditViewController {
    
    var expenseEditViewModel: ExpenseEditViewModel!
    
    private var delegate: ExpenseEditViewControllerDelegate? = nil
    
    override var viewModel: TransactionEditViewModel! {
        return expenseEditViewModel
    }
    
    override func savePromise(amount: String?,
                              convertedAmount: String?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return expenseEditViewModel.saveExpense(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
    
    override func savePromiseResolved() {
        if self.viewModel.isNew {
            self.delegate?.didCreateExpense()
        }
        else {
            self.delegate?.didUpdateExpense()
        }
    }
    
    override func catchSaveError(_ error: Error) {
        switch error {
        case ExpenseCreationError.validation(let validationResults):
            self.showCreationValidationResults(validationResults)
        case ExpenseUpdatingError.validation(let validationResults):
            self.showUpdatingValidationResults(validationResults)
        case APIRequestError.unprocessedEntity(let errors):
            self.show(errors: errors)
        default:
            self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении траты",
                                              theme: .error)
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return expenseEditViewModel.removeExpense()
    }
    
    override func removePromiseResolved() {
        self.delegate?.didRemoveExpense()
    }
    
    override func catchRemoveError(_ error: Error) {
        self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении траты",
                                          theme: .error)
    }
    
    override func isFormValid(amount: String?,
                              convertedAmount: String?,
                              comment: String?,
                              gotAt: Date?) -> Bool {
        return expenseEditViewModel.isFormValid(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
    
    override func didTapStartable() {
        if let expenseSourceSelectViewController = router.viewController(.ExpenseSourceSelectViewController) as? ExpenseSourceSelectViewController {
            
            expenseSourceSelectViewController.set(delegate: self,
                                                  skipExpenseSourceId: nil,
                                                  selectionType: .startable)
            
            slideUp(viewController: expenseSourceSelectViewController)
        }
    }
    
    override func didTapCompletable() {
        if let expenseCategorySelectViewController = router.viewController(.ExpenseCategorySelectViewController) as? ExpenseCategorySelectViewController {
                        
            expenseCategorySelectViewController.set(delegate: self)
            
            slideUp(viewController: expenseCategorySelectViewController)
        }
    }
    
    
}

extension ExpenseEditViewController {
    override func didChange(includedInBalance: Bool) {
        expenseEditViewModel.includedInBalance = includedInBalance
        updateInBalanceUI()
    }
    
    override func updateInBalanceUI() {
        editTableController?.setInBalanceCell(hidden: !expenseEditViewModel.ableToIncludeInBalance)
        editTableController?.inBalanceSwitch.setOn(expenseEditViewModel.includedInBalance, animated: false)
    }
}

extension ExpenseEditViewController : ExpenseEditInputProtocol {
    
    func set(delegate: ExpenseEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseId: Int) {
        expenseEditViewModel.set(expenseId: expenseId)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseCategoryViewModel) {
        expenseEditViewModel.set(startable: startable, completable: completable)
    }
}

extension ExpenseEditViewController {
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func showCreationValidationResults(_ validationResults: [ExpenseCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = creationValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func creationValidationMessageFor(key: ExpenseCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.amountCents, .required):
            return "Укажите сумму списания"
        case (.amountCents, .invalid):
            return "Некорректная сумма списания"
        case (.convertedAmountCents, .required):
            return "Укажите сумму траты"
        case (.convertedAmountCents, .invalid):
            return "Некорректная сумма траты"
        case (.gotAt, .required):
            return "Укажите дату траты"
        case (.gotAt, .invalid):
            return "Некорректная дата траты"
        case (.expenseSourceId, .required):
            return "Укажите кошелек"
        case (.expenseCategoryId, .required):
            return "Укажите категорию трат"
        case (_, _):
            return "Ошибка ввода"
        }
    }
    
    private func showUpdatingValidationResults(_ validationResults: [ExpenseUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = updatingValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func updatingValidationMessageFor(key: ExpenseUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.amountCents, .required):
            return "Укажите сумму списания"
        case (.amountCents, .invalid):
            return "Некорректная сумма списания"
        case (.convertedAmountCents, .required):
            return "Укажите сумму траты"
        case (.convertedAmountCents, .invalid):
            return "Некорректная сумма траты"
        case (.gotAt, .required):
            return "Укажите дату траты"
        case (.gotAt, .invalid):
            return "Некорректная дата траты"
        case (.expenseSourceId, .required):
            return "Укажите кошелек"
        case (.expenseCategoryId, .required):
            return "Укажите категорию трат"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

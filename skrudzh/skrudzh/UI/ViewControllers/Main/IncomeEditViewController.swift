//
//  IncomeEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol IncomeEditViewControllerDelegate {
    func didCreateIncome()
    func didUpdateIncome()
    func didRemoveIncome()
}

protocol IncomeEditInputProtocol {
    func set(delegate: IncomeEditViewControllerDelegate?)
    func set(income: Income)
    func set(startable: IncomeSourceViewModel, completable: ExpenseSourceViewModel)
}

class IncomeEditViewController : TransactionEditViewController {
    
    var incomeEditViewModel: IncomeEditViewModel!
    
    private var delegate: IncomeEditViewControllerDelegate? = nil
    
    override var viewModel: TransactionEditViewModel! {
        return incomeEditViewModel
    }
    
    override func savePromise(amount: String?,
                              convertedAmount: String?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return incomeEditViewModel.saveIncome(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
    
    override func savePromiseResolved() {
        if self.viewModel.isNew {
            self.delegate?.didCreateIncome()
        }
        else {
            self.delegate?.didUpdateIncome()
        }
    }
    
    override func catchSaveError(_ error: Error) {
        switch error {
        case IncomeCreationError.validation(let validationResults):
            self.showCreationValidationResults(validationResults)
        case IncomeUpdatingError.validation(let validationResults):
            self.showUpdatingValidationResults(validationResults)
        case APIRequestError.unprocessedEntity(let errors):
            self.show(errors: errors)
        default:
            self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении дохода",
                                              theme: .error)
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return incomeEditViewModel.removeIncome()
    }
    
    override func removePromiseResolved() {
        self.delegate?.didRemoveIncome()
    }
    
    override func catchRemoveError(_ error: Error) {
        self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении дохода",
                                          theme: .error)
    }
    
    override func isFormValid(amount: String?,
                              convertedAmount: String?,
                              comment: String?,
                              gotAt: Date?) -> Bool {
        return incomeEditViewModel.isFormValid(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
}

extension IncomeEditViewController : IncomeEditInputProtocol {

    func set(delegate: IncomeEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(income: Income) {
        incomeEditViewModel.set(income: income)
    }
    
    func set(startable: IncomeSourceViewModel, completable: ExpenseSourceViewModel) {
        incomeEditViewModel.set(startable: startable, completable: completable)
    }
}

extension IncomeEditViewController {
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func showCreationValidationResults(_ validationResults: [IncomeCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = creationValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func creationValidationMessageFor(key: IncomeCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.amountCents, .required):
            return "Укажите сумму дохода"
        case (.amountCents, .invalid):
            return "Некорректная сумма дохода"
        case (.convertedAmountCents, .required):
            return "Укажите сумму дохода"
        case (.convertedAmountCents, .invalid):
            return "Некорректная сумма дохода"
        case (.gotAt, .required):
            return "Укажите дату дохода"
        case (.gotAt, .invalid):
            return "Некорректная дата дохода"
        case (.incomeSourceId, .required):
            return "Укажите источник дохода"
        case (.expenseSourceId, .required):
            return "Укажите Кошелек"
        case (_, _):
            return "Ошибка ввода"
        }
    }
    
    private func showUpdatingValidationResults(_ validationResults: [IncomeUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = updatingValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func updatingValidationMessageFor(key: IncomeUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.amountCents, .required):
            return "Укажите сумму дохода"
        case (.amountCents, .invalid):
            return "Некорректная сумма дохода"
        case (.convertedAmountCents, .required):
            return "Укажите сумму дохода"
        case (.convertedAmountCents, .invalid):
            return "Некорректная сумма дохода"
        case (.gotAt, .required):
            return "Укажите дату дохода"
        case (.gotAt, .invalid):
            return "Некорректная дата дохода"
        case (.incomeSourceId, .required):
            return "Укажите источник дохода"
        case (.expenseSourceId, .required):
            return "Укажите Кошелек"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

//
//  FundsMoveEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol FundsMoveEditViewControllerDelegate {
    func didCreateFundsMove()
    func didUpdateFundsMove()
    func didRemoveFundsMove()
}

protocol FundsMoveEditInputProtocol {
    func set(delegate: FundsMoveEditViewControllerDelegate?)
    func set(fundsMove: FundsMove)
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel)
}

class FundsMoveEditViewController : TransactionEditViewController {
    
    var fundsMoveEditViewModel: FundsMoveEditViewModel!
    
    private var delegate: FundsMoveEditViewControllerDelegate? = nil
    
    override var viewModel: TransactionEditViewModel! {
        return fundsMoveEditViewModel
    }
    
    override func savePromise(amount: String?,
                              convertedAmount: String?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return fundsMoveEditViewModel.saveFundsMove(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
    
    override func savePromiseResolved() {
        if self.viewModel.isNew {
            self.delegate?.didCreateFundsMove()
        }
        else {
            self.delegate?.didUpdateFundsMove()
        }
    }
    
    override func catchSaveError(_ error: Error) {
        switch error {
        case FundsMoveCreationError.validation(let validationResults):
            self.showCreationValidationResults(validationResults)
        case FundsMoveUpdatingError.validation(let validationResults):
            self.showUpdatingValidationResults(validationResults)
        case APIRequestError.unprocessedEntity(let errors):
            self.show(errors: errors)
        default:
            self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении перевода средств",
                                              theme: .error)
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return fundsMoveEditViewModel.removeFundsMove()
    }
    
    override func removePromiseResolved() {
        self.delegate?.didRemoveFundsMove()
    }
    
    override func catchRemoveError(_ error: Error) {
        self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении перевода средств",
                                          theme: .error)
    }
    
    override func isFormValid(amount: String?,
                              convertedAmount: String?,
                              comment: String?,
                              gotAt: Date?) -> Bool {
        return fundsMoveEditViewModel.isFormValid(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
    
    override func didTapStartable() {
        if let expenseSourceSelectViewController = router.viewController(.ExpenseSourceSelectViewController) as? ExpenseSourceSelectViewController {
            
            expenseSourceSelectViewController.set(delegate: self,
                                                  skipExpenseSourceId: viewModel.completable?.id,
                                                  selectionType: .startable)
            
            slideUp(viewController: expenseSourceSelectViewController)
        }
    }
    
    override func didTapCompletable() {
        if let expenseSourceSelectViewController = router.viewController(.ExpenseSourceSelectViewController) as? ExpenseSourceSelectViewController {
            
            expenseSourceSelectViewController.set(delegate: self,
                                                  skipExpenseSourceId: viewModel.startable?.id,
                                                  selectionType: .completable)
            
            slideUp(viewController: expenseSourceSelectViewController)
        }
    }
}

extension FundsMoveEditViewController : FundsMoveEditInputProtocol {
    
    func set(delegate: FundsMoveEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(fundsMove: FundsMove) {
        fundsMoveEditViewModel.set(fundsMove: fundsMove)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel) {
        fundsMoveEditViewModel.set(startable: startable, completable: completable)
    }
}

extension FundsMoveEditViewController {
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func showCreationValidationResults(_ validationResults: [FundsMoveCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = creationValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func creationValidationMessageFor(key: FundsMoveCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.amountCents, .required):
            return "Укажите сумму списания"
        case (.amountCents, .invalid):
            return "Некорректная сумма списания"
        case (.convertedAmountCents, .required):
            return "Укажите сумму пополнения"
        case (.convertedAmountCents, .invalid):
            return "Некорректная сумма пополнения"
        case (.gotAt, .required):
            return "Укажите дату перевода средств"
        case (.gotAt, .invalid):
            return "Некорректная дата перевода средств"
        case (.expenseSourceFromId, .required):
            return "Укажите кошелек списания"
        case (.expenseSourceToId, .required):
            return "Укажите кошелек пополнения"
        case (_, _):
            return "Ошибка ввода"
        }
    }
    
    private func showUpdatingValidationResults(_ validationResults: [FundsMoveUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = updatingValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func updatingValidationMessageFor(key: FundsMoveUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.amountCents, .required):
            return "Укажите сумму списания"
        case (.amountCents, .invalid):
            return "Некорректная сумма списания"
        case (.convertedAmountCents, .required):
            return "Укажите сумму пополнения"
        case (.convertedAmountCents, .invalid):
            return "Некорректная сумма пополнения"
        case (.gotAt, .required):
            return "Укажите дату перевода средств"
        case (.gotAt, .invalid):
            return "Некорректная дата перевода средств"
        case (.expenseSourceFromId, .required):
            return "Укажите кошелек списания"
        case (.expenseSourceToId, .required):
            return "Укажите кошелек пополнения"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

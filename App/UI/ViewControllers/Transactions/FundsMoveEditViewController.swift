//
//  FundsMoveEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
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
    func set(fundsMoveId: Int)
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?)
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
    
    override func didTapBorrowedTill() {
        let datePickerController = DatePickerViewController()
        datePickerController.set(delegate: BorrowedTillDatePickerControllerDelegate(delegate: self))
        datePickerController.set(date: fundsMoveEditViewModel.borrowedTill, minDate: Date(), maxDate: nil, mode: .date)
        datePickerController.modalPresentationStyle = .custom
        present(datePickerController, animated: true, completion: nil)
    }
    
    override func didTapWhom() {
        let commentController = CommentViewController()
        commentController.set(delegate: WhomCommentControllerDelegate(delegate: self))
        commentController.set(comment: fundsMoveEditViewModel.whom, placeholder: fundsMoveEditViewModel.whomPlaceholder)
        commentController.modalPresentationStyle = .custom
        present(commentController, animated: true, completion: nil)
    }
    
    override func didTapReturn() {
        guard   let startable = fundsMoveEditViewModel.expenseSourceToCompletable,
                let completable = fundsMoveEditViewModel.expenseSourceFromStartable,
                let debtTransaction = fundsMoveEditViewModel.asDebtTransactionForReturn() else { return }
        
        showFundsMoveEditScreen(expenseSourceStartable: startable,
                                expenseSourceCompletable: completable,
                                debtTransaction: debtTransaction)
    }
    
    private func showFundsMoveEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {
        if  let fundsMoveEditNavigationController = router.viewController(.FundsMoveEditNavigationController) as? UINavigationController,
            let fundsMoveEditViewController = fundsMoveEditNavigationController.topViewController as? FundsMoveEditInputProtocol {
            
            fundsMoveEditViewController.set(delegate: self)
            
            fundsMoveEditViewController.set(startable: expenseSourceStartable, completable: expenseSourceCompletable, debtTransaction: debtTransaction)
            
            present(fundsMoveEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension FundsMoveEditViewController: FundsMoveEditViewControllerDelegate {
    func didCreateFundsMove() {
        close {
            self.delegate?.didUpdateFundsMove()
        }        
    }
    
    func didUpdateFundsMove() {
        
    }
    
    func didRemoveFundsMove() {
        
    }
}

protocol WhomSettingDelegate {
    func didChange(whom: String?)
}

class WhomCommentControllerDelegate : CommentViewControllerDelegate {
    let delegate: WhomSettingDelegate?
    
    init(delegate: WhomSettingDelegate?) {
        self.delegate = delegate
    }
    
    func didSave(comment: String?) {
        delegate?.didChange(whom: comment?.trimmed)
    }
}

protocol BorrowedTillSettingDelegate {
    func didChange(borrowedTill: Date?)
}

class BorrowedTillDatePickerControllerDelegate : DatePickerViewControllerDelegate {    
    let delegate: BorrowedTillSettingDelegate?
    
    init(delegate: BorrowedTillSettingDelegate?) {
        self.delegate = delegate
    }
    
    func didSelect(date: Date?) {
        delegate?.didChange(borrowedTill: date)
    }
}

extension FundsMoveEditViewController : WhomSettingDelegate, BorrowedTillSettingDelegate {
    func didChange(borrowedTill: Date?) {
        fundsMoveEditViewModel.borrowedTill = borrowedTill
        updateDebtUI()
    }
    
    func didChange(whom: String?) {
        fundsMoveEditViewModel.whom = whom
        updateDebtUI()
    }
    
    override func updateDebtUI() {        
        editTableController?.setDebtCell(hidden: !fundsMoveEditViewModel.isDebtOrLoan)
        editTableController?.whomButton.setTitle(fundsMoveEditViewModel.whomButtonTitle, for: .normal)
        editTableController?.borrowedTillButton.setTitle(fundsMoveEditViewModel.borrowedTillButtonTitle, for: .normal)
        
        editTableController?.setReturnCell(hidden: fundsMoveEditViewModel.isReturnOptionHidden)
        editTableController?.returnButton.setTitle(fundsMoveEditViewModel.returnTitle, for: .normal)
    }
}

extension FundsMoveEditViewController : FundsMoveEditInputProtocol {
    
    func set(delegate: FundsMoveEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(fundsMoveId: Int) {
        fundsMoveEditViewModel.set(fundsMoveId: fundsMoveId)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {        
        fundsMoveEditViewModel.set(startable: startable, completable: completable, debtTransaction: debtTransaction)
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

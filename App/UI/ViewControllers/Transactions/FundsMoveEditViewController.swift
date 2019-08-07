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

class FundsMoveEditViewController : TransactionEditViewController {
    
    var fundsMoveEditViewModel: FundsMoveEditViewModel!
    
    private var delegate: FundsMoveEditViewControllerDelegate? = nil
    
    override var viewModel: TransactionEditViewModel! {
        return fundsMoveEditViewModel
    }
    
    func set(delegate: FundsMoveEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(fundsMoveId: Int) {
        fundsMoveEditViewModel.set(fundsMoveId: fundsMoveId)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {
        fundsMoveEditViewModel.set(startable: startable, completable: completable, debtTransaction: debtTransaction)
    }
    
    override func savePromise() -> Promise<Void> {
        return fundsMoveEditViewModel.save()
    }
    
    override func didSave() {
        if self.viewModel.isNew {
            self.delegate?.didCreateFundsMove()
        }
        else {
            self.delegate?.didUpdateFundsMove()
        }
    }
        
    override func removePromise() -> Promise<Void> {
        return fundsMoveEditViewModel.removeFundsMove()
    }
    
    override func didRemove() {
        self.delegate?.didRemoveFundsMove()
    }
    
    override func didTapSource() {
        slideUp(viewController: factory.expenseSourceSelectViewController(delegate: self, skipExpenseSourceId: viewModel.completable?.id, selectionType: .startable))
    }
    
    override func didTapDestination() {
        slideUp(viewController: factory.expenseSourceSelectViewController(delegate: self, skipExpenseSourceId: viewModel.startable?.id, selectionType: .completable))
    }
    
    override func didTapBorrowedTill() {
        present(factory.datePickerViewController(delegate: BorrowedTillDatePickerControllerDelegate(delegate: self),
                                                 date: fundsMoveEditViewModel.borrowedTill,
                                                 minDate: Date(),
                                                 maxDate: nil,
                                                 mode: .date))
    }
    
    override func didTapWhom() {
        present(factory.commentViewController(delegate: WhomCommentControllerDelegate(delegate: self),
                                              text: fundsMoveEditViewModel.whom,
                                              placeholder: fundsMoveEditViewModel.whomPlaceholder))
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
        
        present(factory.fundsMoveEditViewController(delegate: self,
                                                    startable: expenseSourceStartable,
                                                    completable: expenseSourceCompletable,
                                                    debtTransaction: debtTransaction))        
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
        tableController.set(cell: tableController.debtCell, hidden: !fundsMoveEditViewModel.isDebtOrLoan, animated: true, reload: false)
        tableController.whomButton.setTitle(fundsMoveEditViewModel.whomButtonTitle, for: .normal)
        tableController.borrowedTillButton.setTitle(fundsMoveEditViewModel.borrowedTillButtonTitle, for: .normal)
        
        tableController.set(cell: tableController.returnCell, hidden: fundsMoveEditViewModel.isReturnOptionHidden, animated: true, reload: true)
        tableController.returnButton.setTitle(fundsMoveEditViewModel.returnTitle, for: .normal)
    }
}

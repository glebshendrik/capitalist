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
    
    override func registerFormFields() -> [String : FormField] {
        return [FundsMove.CodingKeys.expenseSourceFromId.rawValue : tableController.sourceField,
                FundsMove.CodingKeys.expenseSourceToId.rawValue : tableController.destinationField,
                FundsMove.CodingKeys.amountCents.rawValue: tableController.amountField,
                FundsMove.CodingKeys.convertedAmountCents.rawValue: tableController.exchangeField]
    }
    
    func set(delegate: FundsMoveEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(fundsMoveId: Int) {
        fundsMoveEditViewModel.set(fundsMoveId: fundsMoveId)
    }
    
//    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {
//        fundsMoveEditViewModel.set(startable: startable, completable: completable, debtTransaction: debtTransaction)
//    }
    
    func set(startable: ExpenseSourceViewModel?, completable: ExpenseSourceViewModel?, borrow: BorrowViewModel?) {
        fundsMoveEditViewModel.set(startable: startable, completable: completable, borrow: borrow)
    }
    
    override func savePromise() -> Promise<Void> {
        return fundsMoveEditViewModel.save()
    }
    
    override func didSave() {
        super.didSave()
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
        let options = fundsMoveEditViewModel.startableFilter.options
        slideUp(viewController:
            factory.expenseSourceSelectViewController(delegate: self,
                                                      skipExpenseSourceId: viewModel.completable?.id,
                                                      selectionType: .startable,
                                                      noDebts: options.noDebts,
                                                      accountType: options.accountType,
                                                      currency: options.currency))
    }
    
    override func didTapDestination() {
        let options = fundsMoveEditViewModel.completableFilter.options
        slideUp(viewController:
            factory.expenseSourceSelectViewController(delegate: self,
                                                      skipExpenseSourceId: viewModel.startable?.id,                                                      
                                                      selectionType: .completable,
                                                      noDebts: options.noDebts,
                                                      accountType: options.accountType,
                                                      currency: options.currency))
    }    
}



//
//  IncomeEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol IncomeEditViewControllerDelegate {
    func didCreateIncome()
    func didUpdateIncome()
    func didRemoveIncome()
}

class IncomeEditViewController : TransactionEditViewController {
    
    var incomeEditViewModel: IncomeEditViewModel!
    var delegate: IncomeEditViewControllerDelegate?
    
    override var viewModel: TransactionEditViewModel! {
        return incomeEditViewModel
    }
    
    func set(delegate: IncomeEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(incomeId: Int) {
        incomeEditViewModel.set(incomeId: incomeId)
    }
    
    func set(startable: IncomeSourceViewModel, completable: ExpenseSourceViewModel) {
        incomeEditViewModel.set(startable: startable, completable: completable)
    }
    
    override func savePromise() -> Promise<Void> {
        return incomeEditViewModel.save()
    }
    
    override func didSave() {
        if self.viewModel.isNew {
            self.delegate?.didCreateIncome()
        }
        else {
            self.delegate?.didUpdateIncome()
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return incomeEditViewModel.removeIncome()
    }
    
    override func didRemove() {
        self.delegate?.didRemoveIncome()
    }
    
    override func didTapSource() {
        slideUp(viewController: factory.incomeSourceSelectViewController(delegate: self))
    }
    
    override func didTapDestination() {
        slideUp(viewController: factory.expenseSourceSelectViewController(delegate: self,
                                                                          skipExpenseSourceId: viewModel.startable?.id,
                                                                          selectionType: .completable))        
    }
}

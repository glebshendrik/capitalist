//
//  BorrowInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class BorrowInfoViewController : EntityInfoNavigationController {
    var viewModel: BorrowInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.expenseSourceDebt))
    }
                   
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case BorrowInfoField.transaction.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: nil, returningBorrow: viewModel.borrowViewModel))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        guard let borrowType = viewModel.borrowType else { return }
        modal(factory.borrowEditViewController(delegate: self, type: borrowType, borrowId: viewModel.borrowViewModel?.id, source: nil, destination: nil))
    }
}

extension BorrowInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

extension BorrowInfoViewController : BorrowEditViewControllerDelegate {
    func didCreateDebt() {
        
    }
    
    func didCreateLoan() {
        
    }
    
    func didUpdateDebt() {
        refreshData()
    }
    
    func didUpdateLoan() {
        refreshData()
    }
    
    func didRemoveDebt() {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
    
    func didRemoveLoan() {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
}

extension BorrowInfoViewController : TransactionEditViewControllerDelegate {
    var isSelectingTransactionables: Bool {
        return false
    }
    
    func didCreateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
        
    func didUpdateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
        
    func didRemoveTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
}

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
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.common))
    }
                   
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case BorrowInfoField.transaction.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: nil, returningBorrow: viewModel.borrowViewModel, transactionType: nil))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        guard let borrowType = viewModel.borrowType else { return }
        modal(factory.borrowEditViewController(delegate: self, type: borrowType, borrowId: viewModel.borrowViewModel?.id, source: nil, destination: nil))
    }
    
    override func didCreateDebt() {
        
    }
    
    override func didCreateLoan() {
        
    }
    
    override func didUpdateDebt() {
        refreshData()
    }
    
    override func didUpdateLoan() {
        refreshData()
    }
    
    override func didRemoveDebt() {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
    
    override func didRemoveLoan() {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
    
    override var isSelectingTransactionables: Bool {
        return false
    }
    
    override func didCreateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
        
    override func didUpdateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
        
    override func didRemoveTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
}

extension BorrowInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

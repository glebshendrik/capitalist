//
//  CreditInfoViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class CreditInfoViewController : EntityInfoNavigationController {
    var viewModel: CreditInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.common))
    }
        
    override func didTapReminderButton(field: ReminderInfoField?) {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminder))
    }
           
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case CreditInfoField.statistics.identifier:
            modal(factory.statisticsModalViewController(filter: viewModel.asFilter()))
        case CreditInfoField.transaction.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel?.expenseCategoryViewModel, transactionType: .expense))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        modal(factory.creditEditViewController(delegate: self, creditId: viewModel.creditId, destination: nil))
    }
    
    override func didCreateCredit() {
        
    }
    
    override func didUpdateCredit() {
        refreshData()
    }
    
    override func didRemoveCredit() {
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

extension CreditInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

extension CreditInfoViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminder = reminderViewModel
        save()
    }
}

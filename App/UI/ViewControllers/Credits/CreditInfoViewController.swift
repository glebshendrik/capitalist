//
//  CreditInfoViewController.swift
//  Three Baskets
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
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.expenseSourceDebt))
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
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel?.expenseCategoryViewModel))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        modal(factory.creditEditViewController(delegate: self, creditId: viewModel.creditId, destination: nil))
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

extension CreditInfoViewController : CreditEditViewControllerDelegate {
    func didCreateCredit() {
        
    }
    
    func didUpdateCredit() {
        refreshData()
    }
    
    func didRemoveCredit() {
        closeButtonHandler()
    }
}

extension CreditInfoViewController : TransactionEditViewControllerDelegate {
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

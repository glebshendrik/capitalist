//
//  IncomeSourceInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class IncomeSourceInfoViewController : EntityInfoNavigationController {
    var viewModel: IncomeSourceInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
        push(factory.iconsViewController(delegate: self, iconCategory: IconCategory.expenseCategoryRisk))
    }
        
    override func didTapReminderButton(field: ReminderInfoField?) {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminder))
    }
        
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case IncomeSourceInfoField.statistics.identifier:
            push(factory.statisticsViewController(filter: viewModel.asFilter()))
        case IncomeSourceInfoField.transaction.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.incomeSourceViewModel, destination: nil))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: viewModel.incomeSource))
    }
}

extension IncomeSourceInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

extension IncomeSourceInfoViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminder = reminderViewModel
        save()
    }
}

extension IncomeSourceInfoViewController : IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource() {
        
    }
    
    func didUpdateIncomeSource() {
        loadData()
    }
    
    func didRemoveIncomeSource() {
        close()
    }
}

extension IncomeSourceInfoViewController : TransactionEditViewControllerDelegate {
    func didCreateTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func didUpdateTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func didRemoveTransaction(id: Int, type: TransactionType) {
        loadData()
    }
}

//
//  TransactionEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwiftDate

extension TransactionEditViewController : TransactionEditTableControllerDelegate {
    func didAppear() {
        if viewModel.needCurrencyExchange {
            tableController.exchangeField.amountField.becomeFirstResponder()
        } else {
            tableController.amountField.textField.becomeFirstResponder()
        }
    }
    
    func didTapSaveAtYesterday() {
        didSelect(date: Date() - 1.days)
        save()
    }
    
    func didTapCalendar() {
        modal(factory.datePickerViewController(delegate: self,
                                                 date: viewModel.gotAt,
                                                 minDate: nil,
                                                 maxDate: Date(),
                                                 mode: .dateAndTime), animated: true)
    }
    
    func didChange(amount: String?) {
        viewModel.amount = amount
        updateAmountUI()
        updateExchangeAmountsUI()
    }
    
    func didChange(convertedAmount: String?) {
        viewModel.convertedAmount = convertedAmount
        updateExchangeAmountsUI()
    }
    
    func didChange(comment: String?) {
        viewModel.comment = comment
    }
    
    func didTapRemoveButton() {
        let alertController = UIAlertController(title: viewModel.removeQuestion,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.remove()
        })
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
        
    @objc func didTapSource() { }
    
    @objc func didTapDestination() { }
    
    @objc func didChange(includedInBalance: Bool) { }
}

extension TransactionEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        viewModel.gotAt = date
        updateToolbarUI()
    }
}

extension TransactionEditViewController : IncomeSourceSelectViewControllerDelegate {
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel) {
        viewModel.startable = incomeSourceViewModel
        updateUI()
        loadExchangeRate()
    }
}

extension TransactionEditViewController : ExpenseSourceSelectViewControllerDelegate {
    func didSelect(startableExpenseSourceViewModel: ExpenseSourceViewModel) {
        viewModel.startable = startableExpenseSourceViewModel
        updateUI()
        loadExchangeRate()
    }
    
    func didSelect(completableExpenseSourceViewModel: ExpenseSourceViewModel) {
        viewModel.completable = completableExpenseSourceViewModel
        updateUI()
        loadExchangeRate()
    }
}

extension TransactionEditViewController : ExpenseCategorySelectViewControllerDelegate {
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel) {
        viewModel.completable = expenseCategoryViewModel
        updateUI()
        loadExchangeRate()
    }
}

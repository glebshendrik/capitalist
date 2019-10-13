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
          
    func transactionableSelectControllerFor(transactionableType: TransactionableType,
                                            transactionPart: TransactionPart,
                                            skipTransactionable: Transactionable?,
                                            options: ExpenseSourcesFilterOptions) -> UIViewController? {
        switch transactionableType {
        case .incomeSource:
            return factory.incomeSourceSelectViewController(delegate: self)
        case .expenseSource:
            return factory.expenseSourceSelectViewController(delegate: self,
                                                            skipExpenseSourceId: skipTransactionable?.id,
                                                            selectionType: transactionPart,
                                                            noDebts: options.noDebts,
                                                            accountType: options.accountType,
                                                            currency: options.currency)
        case .expenseCategory:
            return factory.expenseCategorySelectViewController(delegate: self)
        default:
            return nil
        }
    }
    func didTapSource() {
        guard let sourceType = viewModel.sourceType else { return }
        
        let viewController = transactionableSelectControllerFor(transactionableType: sourceType,
                                                                transactionPart: .source,
                                                                skipTransactionable: viewModel.destination,
                                                                options: viewModel.sourceFilter.options)

        slideUp(viewController: viewController)
    }
        
    func didTapDestination() {
        guard let destinationType = viewModel.destinationType else { return }
        
        let viewController = transactionableSelectControllerFor(transactionableType: destinationType,
                                                                transactionPart: .destination,
                                                                skipTransactionable: viewModel.source,
                                                                options: viewModel.destinationFilter.options)

        slideUp(viewController: viewController)
    }
}

extension TransactionEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        viewModel.gotAt = date
        updateToolbarUI()
    }
}

extension TransactionEditViewController : IncomeSourceSelectViewControllerDelegate {
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel) {
        viewModel.source = incomeSourceViewModel
        updateUI()
        loadExchangeRate()
    }
}

extension TransactionEditViewController : ExpenseSourceSelectViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel) {
        viewModel.source = sourceExpenseSourceViewModel
        updateUI()
        loadExchangeRate()
    }
    
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel) {
        viewModel.destination = destinationExpenseSourceViewModel
        updateUI()
        loadExchangeRate()
    }
}

extension TransactionEditViewController : ExpenseCategorySelectViewControllerDelegate {
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel) {
        viewModel.destination = expenseCategoryViewModel
        updateUI()
        loadExchangeRate()
    }
}

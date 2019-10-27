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
        update(gotAt: Date() - 1.days)
        save()
    }
    
    func didTapCalendar() {
        modal(factory.datePickerViewController(delegate: self,
                                                 date: viewModel.gotAt,
                                                 minDate: nil,
                                                 maxDate: Date(),
                                                 mode: .dateAndTime), animated: true)
    }
    
    func didTapSource() {
        didTap(transactionableType: viewModel.sourceType,
               transactionPart: .source,
               skipTransactionable: viewModel.destination,
               options: viewModel.sourceFilter.options,
               transactionableTypeCases: sourceTransactionableTypeCases())
    }
        
    func didTapDestination() {
        didTap(transactionableType: viewModel.destinationType,
               transactionPart: .destination,
               skipTransactionable: viewModel.source,
               options: viewModel.destinationFilter.options,
               transactionableTypeCases: destinationTransactionableTypeCases())
    }
    
    func didChange(amount: String?) {
        update(amount: amount)
    }
    
    func didChange(convertedAmount: String?) {
        update(convertedAmount: convertedAmount)
    }
    
    func didChange(isBuyingAsset: Bool) {
        update(isBuyingAsset: isBuyingAsset)
    }
    
    func didChange(comment: String?) {
        update(comment: comment)
    }
    
    func didTapRemoveButton() {
        let actions: [UIAlertAction] = [UIAlertAction(title: "Удалить",
                                                      style: .destructive,
                                                      handler: { _ in
                                                        self.remove()
                                                      })]
        
        sheet(title: viewModel.removeQuestion, actions: actions)
    }
}

extension TransactionEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        update(gotAt: date)        
    }
}

extension TransactionEditViewController : IncomeSourceSelectViewControllerDelegate {
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel) {
        update(source: incomeSourceViewModel)
    }
}

extension TransactionEditViewController : ExpenseSourceSelectViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(source: sourceExpenseSourceViewModel)
    }
    
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(destination: destinationExpenseSourceViewModel)
    }
}

extension TransactionEditViewController : ExpenseCategorySelectViewControllerDelegate {
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel) {
        update(destination: expenseCategoryViewModel)
    }
}

extension TransactionEditViewController : ActiveSelectViewControllerDelegate {
    func didSelect(sourceActiveViewModel: ActiveViewModel) {
        update(source: sourceActiveViewModel)
    }
    
    func didSelect(destinationActiveViewModel: ActiveViewModel) {
        update(destination: destinationActiveViewModel)
    }
}

extension TransactionEditViewController {
    func didTap(transactionableType: TransactionableType?,
                transactionPart: TransactionPart,
                skipTransactionable: Transactionable?,
                options: ExpenseSourcesFilterOptions,
                transactionableTypeCases: [TransactionableType]) {
        
        if viewModel.isNew {
            showTransactionables(transactionableTypes: transactionableTypeCases,
                                 transactionPart: transactionPart,
                                 skipTransactionable: skipTransactionable,
                                 options: options)
        }
        else if let transactionableType = transactionableType {
            showTransactionables(transactionableType: transactionableType,
                                 transactionPart: transactionPart,
                                 skipTransactionable: skipTransactionable,
                                 options: options)
        }
    }
    
    func showTransactionables(transactionableType: TransactionableType,
                              transactionPart: TransactionPart,
                              skipTransactionable: Transactionable?,
                              options: ExpenseSourcesFilterOptions) {
        let viewController = transactionableSelectControllerFor(transactionableType: transactionableType,
                                                                transactionPart: transactionPart,
                                                                skipTransactionable: skipTransactionable,
                                                                options: options)

        slideUp(viewController: viewController)
    }
    
    func showTransactionables(transactionableTypes: [TransactionableType],
                              transactionPart: TransactionPart,
                              skipTransactionable: Transactionable?,
                              options: ExpenseSourcesFilterOptions) {
        
        guard !transactionableTypes.isEmpty else { return }
        
        if transactionableTypes.count == 1, let singleTransactionableType = transactionableTypes.first {
            showTransactionables(transactionableType: singleTransactionableType,
                                 transactionPart: transactionPart,
                                 skipTransactionable: skipTransactionable,
                                 options: options)
        }
        else {
            let actions = transactionableTypes.map { transactionableType in
                return UIAlertAction(title: transactionableType.title(as: transactionPart),
                                     style: .default,
                                     handler: { _ in
                                        self.showTransactionables(transactionableType: transactionableType,
                                                                  transactionPart: transactionPart,
                                                                  skipTransactionable: skipTransactionable,
                                                                  options: options)
                })
            }
            sheet(title: "Выбрать", actions: actions)
        }
    }
    
    func sourceTransactionableTypeCases() -> [TransactionableType] {
        guard let destinationType = viewModel.destinationType else {
            return [.incomeSource, .expenseSource, .active]
        }
        switch destinationType {
        case .expenseCategory:
            return [.expenseSource]
        case .expenseSource:
            return [.incomeSource, .expenseSource, .active]
        case .active:
            return [.incomeSource, .expenseSource]
        default:
            return []
        }
    }
    
    func destinationTransactionableTypeCases() -> [TransactionableType] {
        guard let sourceType = viewModel.sourceType else {
            return [.expenseSource, .expenseCategory, .active]
        }
        switch sourceType {
        case .incomeSource:
            return [.expenseSource, .active]
        case .expenseSource:
            return [.expenseSource, .expenseCategory, .active]
        case .active:
            return [.expenseSource]
        default:
            return []
        }
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
        case .active:
            return factory.activeSelectViewController(delegate: self,
                                                      skipActiveId: skipTransactionable?.id,
                                                      selectionType: transactionPart)
        }
    }
    
    
}

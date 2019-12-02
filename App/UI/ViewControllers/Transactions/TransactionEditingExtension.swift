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
        focusAmountField()        
    }
    
    func didTapSaveAtYesterday() {
        update(gotAt: Date() - 1.days)
    }
    
    func didTapCalendar() {
        modal(factory.datePickerViewController(delegate: self,
                                                 date: viewModel.gotAt,
                                                 minDate: nil,
                                                 maxDate: Date(),
                                                 mode: .dateAndTime), animated: true)
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
    
    func didTapSource() {
        guard viewModel.canChangeSource else { return }
        didTap(transactionableType: viewModel.sourceType,
               transactionPart: .source,
               skipTransactionable: viewModel.destination,
               currency: viewModel.sourceFilterCurrency,
               transactionableTypeCases: sourceTransactionableTypeCases())
    }
        
    func didTapDestination() {
        guard viewModel.canChangeDestination else { return }
        didTap(transactionableType: viewModel.destinationType,
               transactionPart: .destination,
               skipTransactionable: viewModel.source,
               currency: viewModel.destinationFilterCurrency,
               transactionableTypeCases: destinationTransactionableTypeCases())
    }
}

extension TransactionEditViewController {
    func didTap(transactionableType: TransactionableType?,
                transactionPart: TransactionPart,
                skipTransactionable: Transactionable?,
                currency: String?,
                transactionableTypeCases: [TransactionableType]) {
        
        if viewModel.isNew {
            showTransactionables(transactionableTypes: transactionableTypeCases,
                                 transactionPart: transactionPart,
                                 skipTransactionable: skipTransactionable,
                                 currency: currency)
        }
        else if let transactionableType = transactionableType {
            showTransactionables(transactionableType: transactionableType,
                                 transactionPart: transactionPart,
                                 skipTransactionable: skipTransactionable,
                                 currency: currency)
        }
    }
    
    func showTransactionables(transactionableType: TransactionableType,
                              transactionPart: TransactionPart,
                              skipTransactionable: Transactionable?,
                              currency: String?) {
        let viewController = transactionableSelectControllerFor(transactionableType: transactionableType,
                                                                transactionPart: transactionPart,
                                                                skipTransactionable: skipTransactionable,
                                                                currency: currency)

        slideUp(viewController)
    }
    
    func showTransactionables(transactionableTypes: [TransactionableType],
                              transactionPart: TransactionPart,
                              skipTransactionable: Transactionable?,
                              currency: String?) {
        
        let types = transactionableTypes.compactMap { transactionableType -> TransactionableType? in
        
            if  transactionPart == .destination,
                transactionableType == .active,
                let incomeSourceSource = skipTransactionable as? IncomeSourceViewModel,
                incomeSourceSource.activeId == nil {
            
                return nil
            }
            return transactionableType
        }
        
        guard !types.isEmpty else { return }
        
        if types.count == 1, let singleTransactionableType = types.first {
            showTransactionables(transactionableType: singleTransactionableType,
                                 transactionPart: transactionPart,
                                 skipTransactionable: skipTransactionable,
                                 currency: currency)
        }
        else {
            let actions = types.map { transactionableType in
                                
                return UIAlertAction(title: transactionableType.title(as: transactionPart),
                                     style: .default,
                                     handler: { _ in
                                        
                                        if  transactionPart == .source,
                                            transactionableType == .incomeSource,
                                            let activeDestination = skipTransactionable as? ActiveViewModel,
                                            let incomeSourceId = activeDestination.incomeSourceId {
                                                
                                            self.loadSource(id: incomeSourceId, type: transactionableType)
                                        }
                                        else if transactionPart == .destination,
                                                transactionableType == .active,
                                                let incomeSourceSource = skipTransactionable as? IncomeSourceViewModel,
                                                let activeId = incomeSourceSource.activeId {
                                            
                                            self.loadDestination(id: activeId, type: transactionableType)
                                        }
                                        else {
                                            self.showTransactionables(transactionableType: transactionableType,
                                                                      transactionPart: transactionPart,
                                                                      skipTransactionable: skipTransactionable,
                                                                      currency: currency)
                                        }
                                        
                })
            }
            sheet(title: "Выбрать", actions: actions)
        }
    }
    
    func transactionableSelectControllerFor(transactionableType: TransactionableType,
                                            transactionPart: TransactionPart,
                                            skipTransactionable: Transactionable?,
                                            currency: String?) -> UIViewController? {
        switch transactionableType {
        case .incomeSource:
            return factory.incomeSourceSelectViewController(delegate: self)
        case .expenseSource:
            return factory.expenseSourceSelectViewController(delegate: self,
                                                            skipExpenseSourceId: skipTransactionable?.id,
                                                            selectionType: transactionPart,
                                                            currency: currency)
        case .expenseCategory:
            return factory.expenseCategorySelectViewController(delegate: self)
        case .active:
            return factory.activeSelectViewController(delegate: self,
                                                      skipActiveId: skipTransactionable?.id,
                                                      selectionType: transactionPart)
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



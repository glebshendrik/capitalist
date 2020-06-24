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
        view.endEditing(true)
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
    
    func didChange(isSellingAsset: Bool) {
        update(isSellingAsset: isSellingAsset)
    }
    
    func didChange(comment: String?) {
        update(comment: comment)
    }
    
    func didTapRemoveButton() {
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                                      style: .destructive,
                                                      handler: { _ in
                                                        self.remove()
                                                      })]
        
        sheet(title: viewModel.removeQuestion, actions: actions)
    }
    
    func didTapSource() {
        guard   let delegate = delegate,
                !delegate.isSelectingTransactionables else {
            close()
            return
        }
        
        guard viewModel.canChangeSource else { return }
        didTap(transactionableType: viewModel.sourceType,
               transactionPart: .source,
               skipTransactionable: viewModel.destination,
               currency: viewModel.sourceFilterCurrency,
               transactionableTypeCases: sourceTransactionableTypeCases())
    }
        
    func didTapDestination() {
        guard   let delegate = delegate,
                !delegate.isSelectingTransactionables else {
            close()
            return
        }
        
        guard viewModel.canChangeDestination else { return }
        didTap(transactionableType: viewModel.destinationType,
               transactionPart: .destination,
               skipTransactionable: viewModel.source,
               currency: viewModel.destinationFilterCurrency,
               transactionableTypeCases: destinationTransactionableTypeCases())
    }
    
    func didTapSave() {
        save()
    }
    
    func didTapPadButton(type: OperationType) {
        guard let firstResponder = view.firstResponder() as? MoneyTextField else { return }
        
        firstResponder.rewriteModeEnabled = type != .equal
        
        switch firstResponder {
        case tableController.amountField.textField, tableController.exchangeField.amountField:
            viewModel.handleAmount(operation: type)
            update(amount: viewModel.amount)
        case tableController.exchangeField.convertedAmountField:
            viewModel.handleConvertedAmount(operation: type)
            update(convertedAmount: viewModel.convertedAmount)
        default:
            return
        }
    }
}

extension TransactionEditViewController {
    func didTap(transactionableType: TransactionableType?,
                transactionPart: TransactionPart,
                skipTransactionable: Transactionable?,
                currency: String?,
                transactionableTypeCases: [TransactionableType]) {
        
        showTransactionables(transactionableTypes: transactionableTypeCases,
                             transactionPart: transactionPart,
                             skipTransactionable: skipTransactionable,
                             currency: currency)
    }
    
    func showTransactionables(transactionableType: TransactionableType,
                              transactionPart: TransactionPart,
                              skipTransactionable: Transactionable?,
                              currency: String?) {
        let viewController = transactionableSelectControllerFor(transactionableType: transactionableType,
                                                                transactionPart: transactionPart,
                                                                skipTransactionable: nil,
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
            sheet(title: NSLocalizedString("Выбрать", comment: "Выбрать"), actions: actions)
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
        guard   let destinationType = viewModel.destinationType,
                !viewModel.isRemoteTransaction
        else {
            return [.incomeSource, .expenseSource, .active]
        }
        if !viewModel.isNew, let sourceType = viewModel.sourceType {
            return [sourceType]
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
        guard   let sourceType = viewModel.sourceType,
                !viewModel.isRemoteTransaction
        else {
            return [.expenseSource, .expenseCategory, .active]
        }
        if !viewModel.isNew, let destinationType = viewModel.destinationType {
            return [destinationType]
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
    
    func askForReestimateAsset() {
        let reestimateAssetAction = UIAlertAction(title: NSLocalizedString("Переоценить", comment: "Переоценить"),
                                                  style: .default,
                                                  handler: { _ in
                                                    self.showActiveEditScreen(activeViewModel: self.viewModel.source as? ActiveViewModel)
                                                })
        
        sheet(title: NSLocalizedString("Переоценить актив?", comment: "Переоценить актив?"),
              actions: [reestimateAssetAction],
              message: NSLocalizedString("Вы собираетесь полностью продать актив, но сумма указанная в транзакции отличается от стоимости актива. Сначала нужно переоценить актив.", comment: ""),
              preferredStyle: .alert)
    }
    
    func showActiveEditScreen(activeViewModel: ActiveViewModel?) {
        guard let active = activeViewModel?.active else { return }
        modal(factory.activeEditViewController(delegate: self,
                                               active: active,
                                               basketType: active.basketType,
                                               costCents: viewModel.amountCents))
    }
}

extension TransactionEditViewController : ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool) {
        
    }
    
    func didUpdateActive(with basketType: BasketType) {
        guard viewModel.isSellingAsset, let sourceId = viewModel.source?.id, let sourceType = viewModel.sourceType else { return }
        loadSource(id: sourceId, type: sourceType) {
            self.save()
        }
    }
    
    func didRemoveActive(with basketType: BasketType) {
        
    }
}

extension TransactionEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        update(gotAt: date)        
    }
}

extension TransactionEditViewController : IncomeSourceSelectViewControllerDelegate {
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel) {
        update(transactionSource: incomeSourceViewModel, transactionDestination: viewModel?.destination)
    }
}

extension TransactionEditViewController : ExpenseSourcesViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel) {
        if sourceExpenseSourceViewModel.accountConnected && (viewModel.isNew || !viewModel.isDestinationInitiallyConnected) {
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Нельзя выбрать привязанный к банку кошелек", comment: ""),
                                              theme: .error)
            return
        }
        if let destination = viewModel?.destination,
            sourceExpenseSourceViewModel.id == destination.id,
            sourceExpenseSourceViewModel.type == destination.type {
            
            guard !viewModel.isRemoteTransaction else {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Нельзя выбрать привязанный к банку кошелек", comment: ""),
                theme: .error)
                return
            }
            if let source = viewModel?.source, source.type == .expenseSource || source.type == .active {
                update(transactionSource: sourceExpenseSourceViewModel, transactionDestination: viewModel?.source)
            }
            else {
                update(transactionSource: sourceExpenseSourceViewModel, transactionDestination: nil)
            }
        }
        else {
            update(transactionSource: sourceExpenseSourceViewModel, transactionDestination: viewModel?.destination)
        }
    }
    
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel) {
        if destinationExpenseSourceViewModel.accountConnected && (viewModel.isNew || !viewModel.isSourceInitiallyConnected) {
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Нельзя выбрать привязанный к банку кошелек", comment: ""),
                                              theme: .error)
            return
        }
        if let source = viewModel.source,
            destinationExpenseSourceViewModel.id == source.id,
            destinationExpenseSourceViewModel.type == source.type {
            
            guard !viewModel.isRemoteTransaction else {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Нельзя выбрать привязанный к банку кошелек", comment: ""),
                theme: .error)
                return
            }
            if let destination = viewModel?.destination, destination.type == .expenseSource || destination.type == .active {
                update(transactionSource: viewModel?.destination, transactionDestination: destinationExpenseSourceViewModel)
            }
            else {
                update(transactionSource: nil, transactionDestination: destinationExpenseSourceViewModel)
            }
        }
        else {
            update(transactionSource: viewModel?.source, transactionDestination: destinationExpenseSourceViewModel)
        }
    }
}

extension TransactionEditViewController : ExpenseCategorySelectViewControllerDelegate {
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel) {
        update(transactionSource: viewModel?.source, transactionDestination: expenseCategoryViewModel)
    }
}

extension TransactionEditViewController : ActivesViewControllerDelegate {
    func didSelect(sourceActiveViewModel: ActiveViewModel) {
        update(transactionSource: sourceActiveViewModel, transactionDestination: viewModel?.destination)
    }
    
    func didSelect(destinationActiveViewModel: ActiveViewModel) {
        update(transactionSource: viewModel?.source, transactionDestination: destinationActiveViewModel)
    }
}

extension TransactionEditViewController {
    func update(transactionSource: Transactionable?, transactionDestination: Transactionable?) {
        guard let aTransactionSource = transactionSource,
              let aTransactionDestination = transactionDestination else {
            update(source: transactionSource, destination: transactionDestination)
            return
        }
        
        switch (aTransactionSource, aTransactionDestination) {
        case (let source as IncomeSourceViewModel, let destination as ExpenseSourceViewModel):
            showIncomeEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseCategoryViewModel):
            showExpenseEditScreen(source: source, destination: destination)
        default:
            update(source: aTransactionSource, destination: aTransactionDestination)
            return
        }
    }
    
    private func showIncomeEditScreen(source: IncomeSourceViewModel, destination: ExpenseSourceViewModel) {
        if destination.accountConnected && viewModel.isNew {
            return
        }
        if source.isBorrowOrReturn {
            showBorrowingIncomeSheet(source: source, destination: destination)
        }
        else {
            update(source: source, destination: destination)
        }
    }
    
    private func showExpenseEditScreen(source: ExpenseSourceViewModel, destination: ExpenseCategoryViewModel) {
        if source.accountConnected && viewModel.isNew {
            return
        }
        if destination.hasWaitingLoans {
            showBorrowingExpenseSheet(source: source, destination: destination)
        }
        else if destination.isBorrowOrReturn {
            showBorrowEditScreen(type: .debt, source: source, destination: destination)
        }
        else {
            update(source: source, destination: destination)
        }
    }
    
    private func showBorrowingIncomeSheet(source: IncomeSourceViewModel, destination: ExpenseSourceViewModel) {
        let creditAction = UIAlertAction(title: NSLocalizedString("Взять в кредит", comment: "Взять в кредит"), style: .default) { _ in
            self.showCreditEditScreen(destination: destination)
        }
        
        let loanAction = UIAlertAction(title: NSLocalizedString("Занять", comment: "Занять"), style: .default) { _ in
            self.showBorrowEditScreen(type: .loan, source: source, destination: destination)
        }
        
        let returnAction = UIAlertAction(title: NSLocalizedString("Возвращение долга", comment: "Возвращение долга"), style: .default) { _ in
            self.showWaitingBorrows(source.waitingDebts,
                                    source: source,
                                    destination: destination,
                                    borrowType: .debt)
        }
        
        var actions: [UIAlertAction] = [creditAction, loanAction]
        
        if source.hasWaitingDebts {
            actions.append(returnAction)
        }
        
        sheet(title: nil, actions: actions)
    }
    
    private func showBorrowingExpenseSheet(source: ExpenseSourceViewModel, destination: ExpenseCategoryViewModel) {
        guard destination.hasWaitingLoans else { return }
        
        let debtAction = UIAlertAction(title: NSLocalizedString("Одолжить", comment: "Одолжить"), style: .default) { _ in
            self.showBorrowEditScreen(type: .debt, source: source, destination: destination)
        }
        
        let returnAction = UIAlertAction(title: NSLocalizedString("Возвращение займа", comment: "Возвращение займа"), style: .default) { _ in
            self.showWaitingBorrows(destination.waitingLoans,
                                    source: source,
                                    destination: destination,
                                    borrowType: .loan)
        }
        
        sheet(title: nil, actions: [debtAction, returnAction])
    }
    
    private func showWaitingBorrows(_ waitingBorrows: [BorrowViewModel], source: TransactionSource, destination: TransactionDestination, borrowType: BorrowType) {
                
        slideUp(factory.waitingBorrowsViewController(delegate: self,
                                                     source: source,
                                                     destination: destination,
                                                     waitingBorrows: waitingBorrows,
                                                     borrowType: borrowType))
    }
    
    private func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination) {
        closeButtonHandler() {
            self.delegate?.shouldShowBorrowEditScreen(type: type, source: source, destination: destination)
        }
    }
    
    private func showCreditEditScreen(destination: TransactionDestination) {
        closeButtonHandler() {
            self.delegate?.shouldShowCreditEditScreen(destination: destination)
        }
    }
}

extension TransactionEditViewController : WaitingBorrowsViewControllerDelegate {
    func didSelect(borrow: BorrowViewModel, source: TransactionSource, destination: TransactionDestination) {
        update(source: source, destination: destination, returningBorrow: borrow)
    }
}


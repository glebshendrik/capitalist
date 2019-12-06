//
//  StatisticsNavigationControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension StatisticsViewController : TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate {
    
    var isSelectingTransactionables: Bool {
        return false
    }
    
    func didCreateCredit() {
        
    }
    
    func didCreateDebt() {
        
    }
    
    func didCreateLoan() {
        
    }
    
    func didUpdateCredit() {
        loadData()
    }
    
    func didRemoveCredit() {
        loadData()
    }
    
    func didUpdateDebt() {
        loadData()
    }
    
    func didUpdateLoan() {
        loadData()
    }
    
    func didRemoveDebt() {
        loadData()
    }
    
    func didRemoveLoan() {
        loadData()
    }
    
    func didCreateTransaction(id: Int, type: TransactionType) {
    }
    
    func didUpdateTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func didRemoveTransaction(id: Int, type: TransactionType) {
        loadData()
    }
}

extension StatisticsViewController : IncomeSourceEditViewControllerDelegate, ExpenseSourceEditViewControllerDelegate, ExpenseCategoryEditViewControllerDelegate {
    func didCreateIncomeSource() {
        
    }
    
    func didUpdateIncomeSource() {
        reloadFilterAndData()
    }
    
    func didRemoveIncomeSource() {
        didRemoveFilter()
    }
    
    func didCreateExpenseSource() {
        
    }
    
    func didUpdateExpenseSource() {
        reloadFilterAndData()
    }
    
    func didRemoveExpenseSource() {
        didRemoveFilter()
    }
    
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        reloadFilterAndData()
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        didRemoveFilter()
    }
    
    private func didRemoveFilter() {
        guard let filter = viewModel.singleSourceOrDestinationFilter else { return }
        viewModel.remove(sourceOrDestinationFilter: filter)
        loadData()
    }
}

extension StatisticsViewController : StatisticsEditTableViewCellDelegate {
    func didTapStatisticsEditButton() {
        guard let filter = viewModel.singleSourceOrDestinationFilter else { return }
        
        switch filter {
        case let incomeSourceFilter as IncomeSourceTransactionFilter:
            showEditScreen(incomeSource: incomeSourceFilter.incomeSourceViewModel.incomeSource)
        case let expenseSourceFilter as ExpenseSourceTransactionFilter:
            showEditScreen(expenseSource: expenseSourceFilter.expenseSourceViewModel.expenseSource)
        case let expenseCategoryFilter as ExpenseCategoryTransactionFilter:
            showEditScreen(expenseCategory: expenseCategoryFilter.expenseCategoryViewModel.expenseCategory, basketType: expenseCategoryFilter.basketType)
        default:
            return
        }
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: incomeSource))
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: expenseSource))
    }
    
    func showEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType) {
        modal(factory.expenseCategoryEditViewController(delegate: self, expenseCategory: expenseCategory, basketType: basketType))
    }
}

extension StatisticsViewController : FiltersSelectionViewControllerDelegate {
    func showFilters() {
        modal(factory.statisticsFiltersViewController(delegate: self, dateRangeFilter: viewModel.dateRangeFilter, transactionableFilters: viewModel.sourceOrDestinationFilters))
    }
    
    func didSelectFilters(dateRangeFilter: DateRangeTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter]) {
        
        viewModel.set(dateRangeFilter: dateRangeFilter, sourceOrDestinationFilters: sourceOrDestinationFilters)
        updateUI()
    }
}

extension StatisticsViewController {
    func showEdit(transaction: TransactionViewModel) {
        if let borrowId = transaction.borrowId, let borrowType = transaction.borrowType {
            showBorrowInfoScreen(borrowId: borrowId, borrowType: borrowType)
        }
        else if let creditId = transaction.creditId {
            showCreditInfoScreen(creditId: creditId)
        }
        else {
            showTransactionEditScreen(transactionId: transaction.id)
        }
    }
    
    private func showTransactionEditScreen(transactionId: Int) {
        modal(factory.transactionEditViewController(delegate: self, transactionId: transactionId))
    }
        
    func showBorrowInfoScreen(borrowId: Int, borrowType: BorrowType) {
        modal(factory.borrowInfoViewController(borrowId: borrowId, borrowType: borrowType, borrow: nil))
    }
        
    private func showCreditInfoScreen(creditId: Int) {
        modal(factory.creditInfoViewController(creditId: creditId, credit: nil))
    }
}

extension StatisticsViewController : FilterCellDelegate {
    func didTapDeleteButton(filter: SourceOrDestinationTransactionFilter) {
        viewModel.remove(sourceOrDestinationFilter: filter)
        updateUI()
    }
}

extension StatisticsViewController : StatisticsTitleViewDelegate {
    func didTapRemoveDateRangeButton() {
        viewModel.removeDateRangeFilter()
        updateUI()
    }
}

extension StatisticsViewController : GraphTableViewCellDelegate {
    func graphFiltersAndTotalUpdateNeeded() {
        updateGraphFilters()
    }    
        
    func didTapGraphTypeButton() {
        let actions = GraphType.switchList.map { graphType in
            return UIAlertAction(title: graphType.title,
                                 style: .default,
                                 handler: { _ in
                                    self.viewModel.set(graphType: graphType)
                                    self.updateUI()
            })
        }
        
        sheet(title: nil, actions: actions)
    }
    
    func didTapGraphScaleButton() {
        let actions = GraphPeriodScale.switchList.map { graphScale in
            return UIAlertAction(title: graphScale.title,
                                 style: .default,
                                 handler: { _ in
                                    self.viewModel.set(graphScale: graphScale)
                                    self.updateUI()
            })
        }
        
        sheet(title: nil, actions: actions)
    }
    
    func didTapAggregationTypeButton() {
        let actions = viewModel.aggregationTypes.map { aggregationType in
            return UIAlertAction(title: aggregationType.title,
                                 style: .default,
                                 handler: { _ in
                                    self.viewModel.set(aggregationType: aggregationType)                                    
                                    self.updateGraphFilters(updateGraph: true)
            })
        }
        
        sheet(title: nil, actions: actions)
    }
        
    func didTapLinePieSwitchButton() {
        viewModel.switchLinePieChart()
        updateUI()
    }
}

extension StatisticsViewController : GraphFiltersToggleDelegate {
    func didTapFiltersToggleButton() {
        viewModel.toggleGraphFilters()
        updateUI()
    }
    
}

extension StatisticsViewController : TransactionsHeaderDelegate {
    func didTapExportButton() {
        exportTransactions()
    }
}

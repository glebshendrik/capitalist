//
//  StatisticsNavigationControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension StatisticsViewController : IncomeEditViewControllerDelegate, ExpenseEditViewControllerDelegate, FundsMoveEditViewControllerDelegate {
    
    func didCreateIncome() {
    }
    
    func didUpdateIncome() {
        loadData()
    }
    
    func didRemoveIncome() {
        loadData()
    }
    
    func didCreateExpense() {
    }
    
    func didUpdateExpense() {
        loadData()
    }
    
    func didRemoveExpense() {
        loadData()
    }
    
    func didCreateFundsMove() {
    }
    
    func didUpdateFundsMove() {
        loadData()
    }
    
    func didRemoveFundsMove() {
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
        case let incomeSourceFilter as IncomeSourceHistoryTransactionFilter:
            showEditScreen(incomeSource: incomeSourceFilter.incomeSourceViewModel.incomeSource)
        case let expenseSourceFilter as ExpenseSourceHistoryTransactionFilter:
            showEditScreen(expenseSource: expenseSourceFilter.expenseSourceViewModel.expenseSource)
        case let expenseCategoryFilter as ExpenseCategoryHistoryTransactionFilter:
            showEditScreen(expenseCategory: expenseCategoryFilter.expenseCategoryViewModel.expenseCategory, basketType: expenseCategoryFilter.basketType)
        default:
            return
        }
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        if  let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController,
            let incomeSourceEditViewController = incomeSourceEditNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
            incomeSourceEditViewController.set(delegate: self)
            
            if let incomeSource = incomeSource {
                incomeSourceEditViewController.set(incomeSource: incomeSource)
            }
            
            present(incomeSourceEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        if  let expenseSourceEditNavigationController = router.viewController(.ExpenseSourceEditNavigationController) as? UINavigationController,
            let expenseSourceEditViewController = expenseSourceEditNavigationController.topViewController as? ExpenseSourceEditInputProtocol {
            
            expenseSourceEditViewController.set(delegate: self)
            
            if let expenseSource = expenseSource {
                expenseSourceEditViewController.set(expenseSource: expenseSource)
            }
            
            present(expenseSourceEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func showEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType) {
        if  let expenseCategoryEditNavigationController = router.viewController(.ExpenseCategoryEditNavigationController) as? UINavigationController,
            let expenseCategoryEditViewController = expenseCategoryEditNavigationController.topViewController as? ExpenseCategoryEditInputProtocol {
            
            expenseCategoryEditViewController.set(delegate: self)
            expenseCategoryEditViewController.set(basketType: basketType)
            
            if let expenseCategory = expenseCategory {
                expenseCategoryEditViewController.set(expenseCategory: expenseCategory)
            }
            
            present(expenseCategoryEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension StatisticsViewController : FiltersSelectionViewControllerDelegate {
    
    func prepareSegue(_ segue: UIStoryboardSegue) {
        guard   segue.identifier == "showFiltersSelectionScreen",
                let destinationNavigationController = segue.destination as? UINavigationController,
                let destination = destinationNavigationController.topViewController as? FiltersSelectionViewController else { return }
        
        destination.delegate = self
        destination.set(dateRangeFilter: viewModel.dateRangeFilter,
                        sourceOrDestinationFilters: viewModel.sourceOrDestinationFilters)
        
    }
    
    func didSelectFilters(dateRangeFilter: DateRangeHistoryTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter]) {
        
        viewModel.set(dateRangeFilter: dateRangeFilter, sourceOrDestinationFilters: sourceOrDestinationFilters)
        updateUI()
    }
}

extension StatisticsViewController {
    func showEdit(historyTransaction: HistoryTransactionViewModel) {
        switch historyTransaction.transactionableType {
        case .income:
            showIncomeEditScreen(incomeId: historyTransaction.transactionableId)
        case .fundsMove:
            showFundsMoveEditScreen(fundsMoveId: historyTransaction.transactionableId)
        case .expense:
            showExpenseEditScreen(expenseId: historyTransaction.transactionableId)
        }
    }
    
    private func showIncomeEditScreen(incomeId: Int) {
        if  let incomeEditNavigationController = router.viewController(.IncomeEditNavigationController) as? UINavigationController,
            let incomeEditViewController = incomeEditNavigationController.topViewController as? IncomeEditInputProtocol {
            
            incomeEditViewController.set(delegate: self)
            
            incomeEditViewController.set(incomeId: incomeId)
            
            present(incomeEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showFundsMoveEditScreen(fundsMoveId: Int) {
        if  let fundsMoveEditNavigationController = router.viewController(.FundsMoveEditNavigationController) as? UINavigationController,
            let fundsMoveEditViewController = fundsMoveEditNavigationController.topViewController as? FundsMoveEditInputProtocol {
            
            fundsMoveEditViewController.set(delegate: self)
            
            fundsMoveEditViewController.set(fundsMoveId: fundsMoveId)
            
            present(fundsMoveEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showExpenseEditScreen(expenseId: Int) {
        if  let expenseEditNavigationController = router.viewController(.ExpenseEditNavigationController) as? UINavigationController,
            let expenseEditViewController = expenseEditNavigationController.topViewController as? ExpenseEditInputProtocol {
            
            expenseEditViewController.set(delegate: self)
            
            expenseEditViewController.set(expenseId: expenseId)
            
            present(expenseEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension StatisticsViewController : FilterCellDelegate {
    func didTapDeleteButton(filter: SourceOrDestinationHistoryTransactionFilter) {
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
        
        showActionSheet(with: actions)
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
        
        showActionSheet(with: actions)
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
        
        showActionSheet(with: actions)
    }
    
    private func showActionSheet(with actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
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

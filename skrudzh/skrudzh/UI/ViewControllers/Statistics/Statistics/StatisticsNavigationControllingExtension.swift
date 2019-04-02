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
        
    }
}

extension StatisticsViewController {
    func showFiltersSelectionView() {
        
    }
}

extension StatisticsViewController {
    func showEdit(historyTransaction: HistoryTransactionViewModel) {
        
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

//
//  ExpenseEditDelegateExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension MainViewController: ExpenseEditViewControllerDelegate {
    func didCreateExpense() {
        soundsManager.playTransactionCompletedSound()
        updateExpenseDependentData()
    }
    
    func didUpdateExpense() {
        updateExpenseDependentData()
    }
    
    func didRemoveExpense() {
        updateExpenseDependentData()
    }
        
    private func updateExpenseDependentData() {
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
        loadExpenseCategories(by: .risk)
        loadExpenseCategories(by: .safe)
    }
}

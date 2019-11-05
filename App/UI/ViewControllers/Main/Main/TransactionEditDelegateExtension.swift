//
//  TransactionEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController: TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate {
        
    func didCreateDebt() {
        soundsManager.playTransactionCompletedSound()
        updateDebtDependentData()
    }
                
    func didCreateLoan() {
        soundsManager.playTransactionCompletedSound()
        updateLoanDependentData()
    }
            
    func didUpdateDebt() {
        updateDebtDependentData()
    }
        
    func didUpdateLoan() {
        updateLoanDependentData()
    }
        
    func didRemoveDebt() {
        updateDebtDependentData()
    }
        
    func didRemoveLoan() {
        updateLoanDependentData()
    }
    
    func didCreateCredit() {
        updateCreditDependentData()
    }
    
    func didUpdateCredit() {
        updateCreditDependentData()
    }
    
    func didRemoveCredit() {
        updateCreditDependentData()
    }
    
    func didCreateTransaction(id: Int, type: TransactionType) {
        soundsManager.playTransactionCompletedSound()
        updateDataWith(transactionId: id, transactionType: type)
    }
    
    func didUpdateTransaction(id: Int, type: TransactionType) {
        updateDataWith(transactionId: id, transactionType: type)
    }
    
    func didRemoveTransaction(id: Int, type: TransactionType) {
        updateDataWith(transactionId: id, transactionType: type)
    }
    
    private func updateDataWith(transactionId: Int, transactionType: TransactionType) {
        switch transactionType {
        case .income:
            updateIncomeDependentData()
        case .fundsMove:
            updateFundsMoveDependentData()
        case .expense:
            updateExpenseDependentData()
        }
    }
    
    private func updateIncomeDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadActives(by: .risk)
        loadActives(by: .safe)
    }
    
    private func updateFundsMoveDependentData() {
        loadBudget()
        loadExpenseSources()
    }
    
    private func updateExpenseDependentData() {
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
        loadActives(by: .risk)
        loadActives(by: .safe)
    }
    
    private func updateDebtDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
    }
    
    private func updateLoanDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
    }
    
    private func updateCreditDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
    }
}

//
//  TransactionEditDelegateExtension.swift
//  Capitalist
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
    
    func shouldShowCreditEditScreen(source: IncomeSourceViewModel?,
                                    destination: TransactionDestination,
                                    creditingTransaction: Transaction?) {
        showCreditEditScreen(source: source, destination: destination, creditingTransaction: creditingTransaction)
    }

    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        showBorrowEditScreen(type: type, source: source, destination: destination, borrowingTransaction: borrowingTransaction)
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
//        setSelecting(false, animated: true)
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadActives(by: .risk)
        loadActives(by: .safe)
    }
    
    private func updateFundsMoveDependentData() {
//        setSelecting(false, animated: true)
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadActives(by: .risk)
        loadActives(by: .safe)
    }
    
    private func updateExpenseDependentData() {
//        setSelecting(false, animated: true)
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
        loadActives(by: .risk)
        loadActives(by: .safe)
    }
    
    private func updateDebtDependentData() {
//        setSelecting(false, animated: true)
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
    }
    
    private func updateLoanDependentData() {
//        setSelecting(false, animated: true)
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
    }
    
    private func updateCreditDependentData() {
//        setSelecting(false, animated: true)
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
    }
}

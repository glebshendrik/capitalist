//
//  IncomeEditDelegateExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension MainViewController: IncomeEditViewControllerDelegate {
    func didCreateIncome() {
        soundsManager.playTransactionCompletedSound()
        updateIncomeDependentData()
    }
    
    func didUpdateIncome() {
        updateIncomeDependentData()
    }
    
    func didRemoveIncome() {
        updateIncomeDependentData()
    }
    
    private func updateIncomeDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
    }
}

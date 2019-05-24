//
//  FundsMoveEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController: FundsMoveEditViewControllerDelegate {
    func didCreateFundsMove() {
        soundsManager.playTransactionCompletedSound()
        updateFundsMoveDependentData()
    }
    
    func didUpdateFundsMove() {
        updateFundsMoveDependentData()
    }
    
    func didRemoveFundsMove() {
        updateFundsMoveDependentData()
    }
    
    private func updateFundsMoveDependentData() {
        loadBudget()
        loadExpenseSources()
    }
}

//
//  TransactionEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftDate

class TransactionEditViewController : FormNavBarButtonsEditViewController {
    
    var viewModel: TransactionEditViewModel! { return nil }
    var tableController: TransactionEditTableController!
    
    override var shouldLoadData: Bool { return true }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? TransactionEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func updateUI() {
        super.updateUI()
        updateTitleUI()
        updateStartableUI()
        updateCompletableUI()
        updateAmountUI()
        updateExchangeAmountsUI()
        updateToolbarUI()
        updateDebtUI()
        updateInBalanceUI()
    }
    
    func loadExchangeRate() {
        operationStarted()
        
        firstly {
            viewModel.loadExchangeRate()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при загрузке курса валют",
                                              theme: .error)
        }.finally {
            self.operationFinished()
            self.updateUI()
        }
    }
}

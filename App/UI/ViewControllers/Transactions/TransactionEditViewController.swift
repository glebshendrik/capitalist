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

protocol TransactionEditViewControllerDelegate {
    func didCreateTransaction()
    func didUpdateTransaction()
    func didRemoveTransaction()
}

class TransactionEditViewController : FormNavBarButtonsEditViewController {
    var viewModel: TransactionEditViewModel! { return nil }
    var tableController: TransactionEditTableController!
    var delegate: TransactionEditViewControllerDelegate?
    
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return viewModel.title }
    override var loadErrorMessage: String { return "Ошибка загрузки транзакции" }
    
    override func registerFormFields() -> [String : FormField] {
        return [Transaction.CodingKeys.sourceId.rawValue : tableController.sourceField,
                Transaction.CodingKeys.destinationId.rawValue : tableController.destinationField,
                Transaction.CodingKeys.amountCents.rawValue: tableController.amountField,
                Transaction.CodingKeys.convertedAmountCents.rawValue: tableController.exchangeField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? TransactionEditTableController
        self.tableController.delegate = self
    }
    
    override func updateUI() {
        super.updateUI()
        updateToolbarUI()
        updateSourceUI()
        updateDestinationUI()
        updateAmountUI()
        updateExchangeAmountsUI()
        updateCommentUI()
        updateRemoveButtonUI()
        tableController.reloadData(animated: false)
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func didSave() {
        super.didSave()
        if self.viewModel.isNew {
            self.delegate?.didCreateTransaction()
        }
        else {
            self.delegate?.didUpdateTransaction()
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.remove()
    }
    
    override func didRemove() {
        self.delegate?.didRemoveTransaction()
    }
    
    func set(delegate: TransactionEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(transactionId: Int) {
        viewModel.set(transactionId: transactionId)
    }
    
    func set(source: TransactionSource?, destination: TransactionDestination?, returningBorrow: BorrowViewModel?) {
        viewModel.set(source: source, destination: destination, returningBorrow: returningBorrow)
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

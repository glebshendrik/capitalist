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
    var isSelectingTransactionables: Bool { get }
    func didCreateTransaction(id: Int, type: TransactionType)
    func didUpdateTransaction(id: Int, type: TransactionType)
    func didRemoveTransaction(id: Int, type: TransactionType)
}

class TransactionEditViewController : FormNavBarButtonsEditViewController {
    var viewModel: TransactionEditViewModel!
    var tableController: TransactionEditTableController!
    var delegate: TransactionEditViewControllerDelegate?
    
    override var canSave: Bool { return viewModel.canSave }
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return viewModel.title }
    override var loadErrorMessage: String { return NSLocalizedString("Ошибка загрузки транзакции", comment: "Ошибка загрузки транзакции") }
    
    @objc override func keyboardWillAppear() {
        super.keyboardWillAppear()
        viewModel.resetCalculator()
    }

    
    override func registerFormFields() -> [String : FormField] {
        return [Transaction.CodingKeys.sourceId.rawValue : tableController.sourceField,
                Transaction.CodingKeys.destinationId.rawValue : tableController.destinationField,
                "amount": tableController.amountField,
                "converted_amount": tableController.exchangeField]
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
        updateIsBuyingAssetUI()
        updateIsSellingAssetUI()
        updateCommentUI()        
        updateRemoveButtonUI()
        tableController.reloadData(animated: false)
        focusAmountField()
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func save() {
        if viewModel.shouldAskForReestimateAsset {
            askForReestimateAsset()
        }
        else {
            super.save()
        }
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func didSave() {
        super.didSave()
        
        guard   let transactionType = viewModel.transactionType,
                let transactionId = viewModel.transaction?.id else { return }
        
        if viewModel.isNew {
            self.delegate?.didCreateTransaction(id: transactionId, type: transactionType)
        }
        else {
            self.delegate?.didUpdateTransaction(id: transactionId, type: transactionType)
        }
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.remove()
    }
    
    override func didRemove() {
        guard   let transactionType = viewModel.transactionType,
                let transactionId = viewModel.transactionId else { return }
        self.delegate?.didRemoveTransaction(id: transactionId, type: transactionType)
    }
    
    func set(delegate: TransactionEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(transactionId: Int) {
        viewModel.set(transactionId: transactionId)
    }
    
    func set(source: Transactionable?, destination: Transactionable?, returningBorrow: BorrowViewModel?) {
        viewModel.set(source: source, destination: destination, returningBorrow: returningBorrow)
    }
    
    func loadExchangeRate() {
        operationStarted()
        
        firstly {
            viewModel.loadExchangeRate()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка при загрузке курса валют", comment: "Ошибка при загрузке курса валют"),
                                              theme: .error)
        }.finally {
            self.operationFinished()
            self.updateUI()
        }
    }
    
    func loadSource(id: Int, type: TransactionableType, completion: (() -> Void)? = nil) {
        operationStarted()
        
        firstly {
            viewModel.loadSource(id: id, type: type)
        }.done {
            self.operationFinished()
            self.updateUI()
            completion?()
        }.catch { _ in
            self.operationFinished()
            self.updateUI()
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка при загрузке источника", comment: "Ошибка при загрузке источника"),
                                              theme: .error)
        }
    }
    
    func loadDestination(id: Int, type: TransactionableType) {
        operationStarted()
        
        firstly {
            viewModel.loadDestination(id: id, type: type)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка при загрузке назначения", comment: "Ошибка при загрузке назначения"),
                                              theme: .error)
        }.finally {
            self.operationFinished()
            self.updateUI()
        }
    }
}

//
//  TransactionEditViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftDate

protocol TransactionEditViewControllerDelegate : class {
    var isSelectingTransactionables: Bool { get }
    func didCreateTransaction(id: Int, type: TransactionType)
    func didUpdateTransaction(id: Int, type: TransactionType)
    func didRemoveTransaction(id: Int, type: TransactionType)
    func shouldShowCreditEditScreen(destination: TransactionDestination)
    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination)
}

class TransactionEditViewController : FormNavBarButtonsEditViewController {
    var viewModel: TransactionEditViewModel!
    var tableController: TransactionEditTableController!
    weak var delegate: TransactionEditViewControllerDelegate?
    
    var titleView: TransactionEditTitleView!
    
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
    
    override func setupNavigationBar() {
        self.titleView = TransactionEditTitleView(frame: CGRect.zero)
        navigationItem.titleView = titleView
        super.setupNavigationBar()
    }
    
    override func updateNavigationItemUI() {
        titleView.set(title: viewModel.title)
        
        let highlightColor = UIColor.by(viewModel.highlightColor)
        titleView.set(highlightColor: highlightColor)
        
        navigationItem.rightBarButtonItem?.tintColor = highlightColor
        saveBarButton.tintColor = highlightColor
        
        saveButton?.backgroundColor = highlightColor
        saveButton?.backgroundColorForNormal = highlightColor
        
        tableController.saveButton.backgroundColor = highlightColor
        tableController.saveButton.backgroundColorForNormal = highlightColor
        
        tableController.amountSaveButton.backgroundColor = highlightColor
        tableController.amountSaveButton.backgroundColorForNormal = highlightColor        
        
        registerFormFields().values.forEach { $0.focusedBackgroundColor = highlightColor }
        tableController.exchangeField.focusedFieldBackgroundColor = highlightColor
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
    
    func set(transactionId: Int, transactionType: TransactionType?) {
        viewModel.set(transactionId: transactionId, transactionType: transactionType)
    }
    
    func set(source: Transactionable?, destination: Transactionable?, returningBorrow: BorrowViewModel?, transactionType: TransactionType?) {
        viewModel.set(source: source, destination: destination, returningBorrow: returningBorrow, transactionType: transactionType)
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

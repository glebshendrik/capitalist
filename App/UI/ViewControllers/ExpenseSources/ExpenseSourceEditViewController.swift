//
//  ExpenseSourceEditViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import PopupDialog

protocol ExpenseSourceEditViewControllerDelegate : class {
    func didCreateExpenseSource()
    func didUpdateExpenseSource()
    func didRemoveExpenseSource()
}

class ExpenseSourceEditViewController : FormTransactionsDependableEditViewController, BankConnectableProtocol {
    
    var viewModel: ExpenseSourceEditViewModel!
    var bankConnectableViewModel: BankConnectableViewModel! {
        return viewModel.bankConnectableViewModel
    }
    
    weak var delegate: ExpenseSourceEditViewControllerDelegate?
    var tableController: ExpenseSourceEditTableController!
    
    override var shouldLoadData: Bool { return viewModel.isNew }
    override var formTitle: String {
        return viewModel.isNew
            ? NSLocalizedString("Новый кошелек", comment: "Новый кошелек")
            : NSLocalizedString("Кошелек", comment: "Кошелек")
    }
    override var saveErrorMessage: String {
        return NSLocalizedString("Ошибка при сохранении кошелька", comment: "Ошибка при сохранении кошелька")
    }
    
    override var removeErrorMessage: String {
        return NSLocalizedString("Ошибка при удалении кошелька", comment: "Ошибка при удалении кошелька")
    }
    
    override var removeQuestionMessage: String { return TransactionableType.expenseSource.removeQuestion }
    
    override func registerFormFields() -> [String : FormField] {
        return [ExpenseSource.CodingKeys.name.rawValue : tableController.nameField,
                ExpenseSource.CodingKeys.cardType.rawValue : tableController.cardTypeField,
                ExpenseSource.CodingKeys.currency.rawValue : tableController.currencyField,
                ExpenseSource.CodingKeys.amountCents.rawValue : tableController.amountField,
                ExpenseSource.CodingKeys.creditLimitCents.rawValue : tableController.creditLimitField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {        
        self.tableController = tableController as? ExpenseSourceEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
        
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeExpenseSource(deleteTransactions: deleteTransactions)
    }
    
    override func didLoadData() {
        super.didLoadData()
        if viewModel.needToShowExamples {
            view.endEditing(true)
            slideUp(factory.transactionableExamplesViewController(delegate: self,
                                                                  transactionableType: .expenseSource,
                                                                  isUsed: false))
        }
        else {
            suggestBankConnection()
        }
    }
    
    override func didSave() {
        updateUI()
        if viewModel.isNew {
            delegate?.didCreateExpenseSource()
        }
        else {
            delegate?.didUpdateExpenseSource()
        }
        if !bankConnectableViewModel.intentToSave || !isCurrentTopmostPresentedViewController && bankConnectableViewModel.fetchingStarted {
            // formally will close the form
            super.didSave()
        } else if bankConnectableViewModel.reconnectNeeded {
            setupConnection()
        }
        bankConnectableViewModel.intentToSave = false        
    }
    
    override func didRemove() {
        delegate?.didRemoveExpenseSource()
    }
    
    override func updateUI() {
        updateTextFieldsUI()
        updateCardTypeUI()
        updateCurrencyUI()
        updateIconUI()
        updateBankUI()
        updateRemoveButtonUI()
        updateTableUI(animated: false)
        focusFirstEmptyField()
    }
        
    func refreshData() {
        loadData()
    }
}

extension ExpenseSourceEditViewController {
    func set(delegate: ExpenseSourceEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseSource: ExpenseSource) {
        viewModel.set(expenseSource: expenseSource)
    }
}

extension ExpenseSourceEditViewController : Updatable {
    func update() {
        refreshData()
    }
}

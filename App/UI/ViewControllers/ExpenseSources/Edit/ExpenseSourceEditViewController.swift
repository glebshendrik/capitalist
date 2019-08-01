//
//  ExpenseSourceEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource()
    func didUpdateExpenseSource()
    func didRemoveExpenseSource()
}

class ExpenseSourceEditViewController : FormTransactionsDependableEditViewController {

    var viewModel: ExpenseSourceEditViewModel!
    var delegate: ExpenseSourceEditViewControllerDelegate?
    var tableController: ExpenseSourceEditTableController!
    
    override var shouldLoadData: Bool { return viewModel.isNew }
    override var formTitle: String {
        return viewModel.isNew ? "Новый кошелек" : "Кошелек"
    }
    override var saveErrorMessage: String { return "Ошибка при сохранении кошелька" }
    override var removeErrorMessage: String { return "Ошибка при удалении кошелька" }
    override var removeQuestionMessage: String { return "Удалить кошелек?" }
    
    override func registerFormFields() -> [String : FormTextField] {
        return [ExpenseSource.CodingKeys.name.rawValue : tableController.nameField,
                ExpenseSource.CodingKeys.amountCurrency.rawValue : tableController.currencyField,
                ExpenseSource.CodingKeys.amountCents.rawValue : tableController.amountField,
                ExpenseSource.CodingKeys.creditLimitCents.rawValue : tableController.creditLimitField,
                ExpenseSource.CodingKeys.goalAmountCents.rawValue : tableController.goalAmountField]
    }
    
    override func setup(tableController: FloatingFieldsStaticTableViewController) {        
        self.tableController = tableController as? ExpenseSourceEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadDefaultCurrency()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeExpenseSource(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        if viewModel.isNew {
            delegate?.didCreateExpenseSource()
        }
        else {
            delegate?.didUpdateExpenseSource()
        }
    }
    
    override func didRemove() {
        delegate?.didRemoveExpenseSource()
    }
    
    override func updateUI() {
        updateTextFieldsUI()
        updateCurrencyUI()
        updateIconUI()
        updateBankUI()
        updateRemoveButtonUI()
        updateTableUI(animated: false)
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

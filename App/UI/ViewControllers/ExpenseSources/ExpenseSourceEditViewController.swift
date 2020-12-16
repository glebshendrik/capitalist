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
        return viewModel.loadDefaultCurrency()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeExpenseSource(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        super.didSave()
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
        updateCardTypeUI()
        updateCurrencyUI()
        updateIconUI()
        updateBankUI()
        updateRemoveButtonUI()
        updateTableUI(animated: false)
        focusFirstEmptyField()
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

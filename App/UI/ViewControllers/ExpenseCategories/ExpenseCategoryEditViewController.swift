//
//  ExpenseCategoryEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 18/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String)
    func didUpdateExpenseCategory(with basketType: BasketType)
    func didRemoveExpenseCategory(with basketType: BasketType)
}

class ExpenseCategoryEditViewController : FormTransactionsDependableEditViewController {
    
    var viewModel: ExpenseCategoryEditViewModel!
    var tableController: ExpenseCategoryEditTableController!
    var delegate: ExpenseCategoryEditViewControllerDelegate?    
    
    override var shouldLoadData: Bool { return viewModel.isNew }
    override var formTitle: String {
        return viewModel.isNew ? "Новая категория трат" : "Категория трат"
    }
    override var saveErrorMessage: String { return "Ошибка при сохранении категории трат" }
    override var removeErrorMessage: String { return "Ошибка при удалении категории трат" }
    override var removeQuestionMessage: String { return "Удалить категорию трат?" }
    
    override func registerFormFields() -> [String : FormField] {
        return [ExpenseCategory.CodingKeys.name.rawValue : tableController.nameField,
                ExpenseCategory.CodingKeys.monthlyPlannedCurrency.rawValue : tableController.currencyField,
                ExpenseCategory.CodingKeys.incomeSourceCurrency.rawValue : tableController.incomeSourceCurrencyField,
                ExpenseCategory.CodingKeys.monthlyPlannedCents.rawValue : tableController.monthlyPlannedField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ExpenseCategoryEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadDefaultCurrency()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeExpenseCategory(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        if viewModel.isNew {
            delegate?.didCreateExpenseCategory(with: viewModel.basketType, name: viewModel.name!)
        }
        else {
            delegate?.didUpdateExpenseCategory(with: viewModel.basketType)
        }
    }
    
    override func didRemove() {
        delegate?.didRemoveExpenseCategory(with: viewModel.basketType)
    }
    
    override func updateUI() {
        updateIconUI()
        updateTextFieldsUI()
        updateCurrencyUI()
        updateIncomeSourceCurrencyUI()
        updateReminderUI()
        updateRemoveButtonUI()
    }
}

extension ExpenseCategoryEditViewController {
    func set(delegate: ExpenseCategoryEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseCategory: ExpenseCategory) {
        viewModel.set(expenseCategory: expenseCategory)
    }
    
    func set(basketType: BasketType) {
        viewModel.set(basketType: basketType)
    }
}

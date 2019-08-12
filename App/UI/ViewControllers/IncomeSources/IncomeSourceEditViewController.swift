//
//  IncomeSourceEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource()
    func didUpdateIncomeSource()
    func didRemoveIncomeSource()
}

class IncomeSourceEditViewController : FormTransactionsDependableEditViewController {

    var viewModel: IncomeSourceEditViewModel!
    private var delegate: IncomeSourceEditViewControllerDelegate?
    var tableController: IncomeSourceEditTableController!
        
    override var shouldLoadData: Bool { return viewModel.isNew }
    override var formTitle: String {
        return viewModel.isNew ? "Новый источник доходов" : "Источник доходов"
    }
    override var saveErrorMessage: String { return "Ошибка при сохранении источника доходов" }
    override var removeErrorMessage: String { return "Ошибка при удалении источника доходов" }
    override var removeQuestionMessage: String { return "Удалить источник доходов?" }
    
    override func registerFormFields() -> [String : FormField] {
        return [IncomeSource.CodingKeys.name.rawValue : tableController.nameField,
                IncomeSource.CodingKeys.currency.rawValue : tableController.currencyField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? IncomeSourceEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadDefaultCurrency()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeIncomeSource(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        super.didSave()
        if self.viewModel.isNew {
            self.delegate?.didCreateIncomeSource()
        }
        else {
            self.delegate?.didUpdateIncomeSource()
        }
    }
    
    override func didRemove() {
        self.delegate?.didRemoveIncomeSource()
    }
    
    override func updateUI() {
        updateTextFieldsUI()
        updateCurrencyUI()
        updateReminderUI()
        updateRemoveButtonUI()
    }  
}

extension IncomeSourceEditViewController {
    func set(delegate: IncomeSourceEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(incomeSource: IncomeSource) {
        viewModel.set(incomeSource: incomeSource)
    }
}

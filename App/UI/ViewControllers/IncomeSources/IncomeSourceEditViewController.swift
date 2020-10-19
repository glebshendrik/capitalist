//
//  IncomeSourceEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol IncomeSourceEditViewControllerDelegate : class {
    func didCreateIncomeSource()
    func didUpdateIncomeSource()
    func didRemoveIncomeSource()
}

class IncomeSourceEditViewController : FormTransactionsDependableEditViewController {

    var viewModel: IncomeSourceEditViewModel!
    private weak var delegate: IncomeSourceEditViewControllerDelegate?
    var tableController: IncomeSourceEditTableController!
        
    override var shouldLoadData: Bool { return viewModel.isNew }
    override var formTitle: String {
        return viewModel.isNew
            ? NSLocalizedString("Новый источник доходов", comment: "Новый источник доходов")
            : NSLocalizedString("Источник доходов", comment: "Источник доходов")
    }
    override var saveErrorMessage: String {
        return NSLocalizedString("Ошибка при сохранении источника доходов", comment: "Ошибка при сохранении источника доходов")
    }
    
    override var removeErrorMessage: String {
        return NSLocalizedString("Ошибка при удалении источника доходов", comment: "Ошибка при удалении источника доходов")
    }
    
    override var removeQuestionMessage: String { return TransactionableType.incomeSource.removeQuestion }
    
    override func registerFormFields() -> [String : FormField] {
        return [IncomeSource.CodingKeys.name.rawValue : tableController.nameField,
                IncomeSource.CodingKeys.currency.rawValue : tableController.currencyField,
                IncomeSource.CodingKeys.monthlyPlannedCents.rawValue : tableController.monthlyPlannedField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? IncomeSourceEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeIncomeSource(deleteTransactions: deleteTransactions)
    }
    
    override func didLoadData() {
        super.didLoadData()
        if viewModel.needToShowExamples {
            view.endEditing(true)
            slideUp(factory.transactionableExamplesViewController(delegate: self,
                                                                  transactionableType: .incomeSource,
                                                                  isUsed: false))
        }
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
        updateIconUI()
        updateTextFieldsUI()
        updateCurrencyUI()
        updateReminderUI()
        updateRemoveButtonUI()
        tableController.reloadData(animated: false)
        focusFirstEmptyField()
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

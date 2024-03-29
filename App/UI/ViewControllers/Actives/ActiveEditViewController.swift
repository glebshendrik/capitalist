//
//  ActiveEditViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 21/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ActiveEditViewControllerDelegate : class {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool)
    func didUpdateActive(with basketType: BasketType)
    func didRemoveActive(with basketType: BasketType)
}

class ActiveEditViewController : FormTransactionsDependableEditViewController {
        
    var viewModel: ActiveEditViewModel!
    var tableController: ActiveEditTableController!
    weak var delegate: ActiveEditViewControllerDelegate?
    
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return viewModel.title }
    override var saveErrorMessage: String { return NSLocalizedString("Ошибка при сохранении", comment: "Ошибка при сохранении") }
    override var removeErrorMessage: String { return NSLocalizedString("Ошибка при удалении", comment: "Ошибка при удалении") }
    override var removeQuestionMessage: String { return TransactionableType.active.removeQuestion }
    
    override func registerFormFields() -> [String : FormField] {
        return [ActiveCreationForm.CodingKeys.name.rawValue : tableController.nameField,
                "active_type" : tableController.activeTypeField,
                ActiveCreationForm.CodingKeys.currency.rawValue : tableController.currencyField,
                ActiveCreationTransactionNestedAttributes.CodingKeys.sourceId.rawValue : tableController.expenseSourceField,
                ActiveCreationForm.CodingKeys.costCents.rawValue : tableController.costField,
                ActiveCreationForm.CodingKeys.alreadyPaidCents.rawValue : tableController.alreadyPaidField,
                ActiveCreationForm.CodingKeys.goalAmountCents.rawValue : tableController.goalAmountField,
                ActiveCreationForm.CodingKeys.monthlyPaymentCents.rawValue : tableController.monthlyPaymentField,
                ActiveCreationForm.CodingKeys.plannedIncomeType.rawValue : tableController.activeIncomeTypeField,
                ActiveCreationForm.CodingKeys.annualIncomePercent.rawValue : tableController.annualPercentField,
                ActiveCreationForm.CodingKeys.monthlyPlannedIncomeCents.rawValue : tableController.monthlyPlannedIncomeField]
    }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? ActiveEditTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func savePromise() -> Promise<Void> {
        return viewModel.save()
    }
    
    override func removePromise() -> Promise<Void> {
        return viewModel.removeActive(deleteTransactions: deleteTransactions)
    }
    
    override func didSave() {
        super.didSave()
        if viewModel.isNew {
            delegate?.didCreateActive(with: viewModel.basketType, name: viewModel.name!, isIncomePlanned: viewModel.isIncomePlanned)
        }
        else {
            delegate?.didUpdateActive(with: viewModel.basketType)
        }
    }
    
    override func didRemove() {
        delegate?.didRemoveActive(with: viewModel.basketType)
    }
    
    override func updateUI() {
        updateIconUI()
        updateActiveTypeUI()
        updateTextFieldsUI()
        updateCurrencyUI()
        updateExpenseSourceUI()
        updateIsIncomePlannedUI()
        updateActiveIncomeTypeUI()
        updateReminderUI()
        updateRemoveButtonUI()
        updateBankUI()
        updateTableUI(animated: false)
        focusFirstEmptyField()
    }
}

extension ActiveEditViewController {
    func set(delegate: ActiveEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(activeId: Int) {
        viewModel.set(activeId: activeId)
    }
    
    func set(basketType: BasketType) {
        viewModel.set(basketType: basketType)
    }
    
    func set(active: Active) {        
        viewModel.set(active: active)
    }
    
    func set(costCents: Int?) {
        viewModel.set(costCents: costCents)
    }
}

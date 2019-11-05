//
//  ActiveEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool)
    func didUpdateActive(with basketType: BasketType)
    func didRemoveActive(with basketType: BasketType)
}

class ActiveEditViewController : FormTransactionsDependableEditViewController {
        
    var viewModel: ActiveEditViewModel!
    var tableController: ActiveEditTableController!
    var delegate: ActiveEditViewControllerDelegate?
    
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return viewModel.title }
    override var saveErrorMessage: String { return "Ошибка при сохранении" }
    override var removeErrorMessage: String { return "Ошибка при удалении" }
    override var removeQuestionMessage: String { return TransactionableType.active.removeQuestion }
    
    override func registerFormFields() -> [String : FormField] {
        return [Active.CodingKeys.name.rawValue : tableController.nameField,
                Active.CodingKeys.activeType.rawValue : tableController.activeIncomeTypeField,
                Active.CodingKeys.currency.rawValue : tableController.currencyField,
                Active.CodingKeys.costCents.rawValue : tableController.costField,
                Active.CodingKeys.alreadyPaidCents.rawValue : tableController.alreadyPaidField,
                Active.CodingKeys.goalAmountCents.rawValue : tableController.goalAmountField,
                Active.CodingKeys.monthlyPaymentCents.rawValue : tableController.monthlyPaymentField,
                Active.CodingKeys.plannedIncomeType.rawValue : tableController.activeIncomeTypeField,
                Active.CodingKeys.annualIncomePercent.rawValue : tableController.annualPercentField,
                Active.CodingKeys.monthlyPlannedIncomeCents.rawValue : tableController.monthlyPlannedIncomeField]
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
        updateIsIncomePlannedUI()
        updateActiveIncomeTypeUI()
        updateReminderUI()
        updateRemoveButtonUI()
        updateTableUI(animated: false)
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
}

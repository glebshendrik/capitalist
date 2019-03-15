//
//  ExpenseSourceEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource()
    func didUpdateExpenseSource()
    func didRemoveExpenseSource()
}

protocol ExpenseSourceEditInputProtocol {
    func set(expenseSource: ExpenseSource)
    func set(delegate: ExpenseSourceEditViewControllerDelegate?)
}

class ExpenseSourceEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    var viewModel: ExpenseSourceEditViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    private var delegate: ExpenseSourceEditViewControllerDelegate?
    
    private var editTableController: ExpenseSourceEditTableController?
    
    private var expenseSourceName: String? {
        return editTableController?.expenseSourceNameTextField?.text?.trimmed
    }
    
    private var expenseSourceAmount: String? {
        return editTableController?.expenseSourceAmountTextField?.text?.trimmed
    }
    
    private var expenseSourceGoalAmount: String? {
        return editTableController?.expenseSourceGoalAmountTextField?.text?.trimmed
    }
    
    private var selectedIconURL: URL? {
        return viewModel.selectedIconURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.mainNavBarColor        
        setRemoveButton(hidden: viewModel.isNew)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Удалить кошелек?",
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.remove(deleteTransactions: false)
        })
        
        alertController.addAction(title: "Удалить вместе с транзакциями",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.remove(deleteTransactions: true)
        })
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
    
    private func save() {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        firstly {
            viewModel.saveExpenseSource(with: self.expenseSourceName, amount: self.expenseSourceAmount, iconURL: self.selectedIconURL, goalAmount: self.expenseSourceGoalAmount)
        }.done {
            if self.viewModel.isNew {
                self.delegate?.didCreateExpenseSource()
            }
            else {
                self.delegate?.didUpdateExpenseSource()
            }
            self.close()
        }.catch { error in
            switch error {
            case ExpenseSourceCreationError.validation(let validationResults):
                self.showCreateionValidationResults(validationResults)
            case ExpenseSourceUpdatingError.validation(let validationResults):
                self.showUpdatingValidationResults(validationResults)
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении кошелька",
                                                  theme: .error)
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
        }
    }
    
    private func remove(deleteTransactions: Bool) {
        setActivityIndicator(hidden: false)
        removeButton.isEnabled = false
        
        firstly {
            viewModel.removeExpenseSource(deleteTransactions: deleteTransactions)
        }.done {
            self.delegate?.didRemoveExpenseSource()
            self.close()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении кошелька",
                                              theme: .error)
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.removeButton.isUserInteractionEnabled = true
        }
    }
    
    private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ExpenseSourceEditViewController : ExpenseSourceEditTableControllerDelegate {
    var canChangeCurrency: Bool {
        return viewModel.isNew
    }
    
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
    
    var isExpenseSourceGoalType: Bool {
        return viewModel.isGoal
    }
    
    func didSwitchType(isGoal: Bool) {
        viewModel.isGoal = isGoal
        updateIconUI()
        updateGoalUI()
        validateUI()
    }
    
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
    
    func validationNeeded() {
        validateUI()
    }
    
    private func validateUI() {
//        let isFormValid = viewModel.isFormValid(with: expenseSourceName, amount: expenseSourceAmount, iconURL: selectedIconURL, goalAmount: expenseSourceGoalAmount)
//        let invalidColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
//        let validColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
//        saveButton.isEnabled = isFormValid
//        saveButton.backgroundColor = isFormValid ? validColor : invalidColor
    }
}

extension ExpenseSourceEditViewController {
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func showCreateionValidationResults(_ validationResults: [ExpenseSourceCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = creationValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func creationValidationMessageFor(key: ExpenseSourceCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.name, .required):
            return "Укажите название"
        case (.amountCents, .required):
            return "Укажите текущий баланс"
        case (.amountCents, .invalid):
            return "Некорректный текущий баланс"
        case (.goalAmountCents, .required):
            return "Укажите сколько вы хотите накопить"
        case (.goalAmountCents, .invalid):
            return "Некорректная сумма цели"
        case (_, _):
            return "Ошибка ввода"
        }
    }
    
    private func showUpdatingValidationResults(_ validationResults: [ExpenseSourceUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = updatingValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func updatingValidationMessageFor(key: ExpenseSourceUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.name, .required):
            return "Укажите название"
        case (.amountCents, .required):
            return "Укажите текущий баланс"
        case (.amountCents, .invalid):
            return "Некорректный текущий баланс"
        case (.goalAmountCents, .required):
            return "Укажите сколько вы хотите накопить"
        case (.goalAmountCents, .invalid):
            return "Некорректная сумма цели"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

extension ExpenseSourceEditViewController : ExpenseSourceEditInputProtocol {
    func set(delegate: ExpenseSourceEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseSource: ExpenseSource) {
        viewModel.set(expenseSource: expenseSource)
    }
    
    private func updateUI() {
        editTableController?.expenseSourceNameTextField?.text = viewModel.name        
        editTableController?.expenseSourceAmountTextField?.text = viewModel.amount
        editTableController?.expenseSourceGoalAmountTextField?.text = viewModel.goalAmount
        updateCurrencyUI()
        updateIconUI()
        updateGoalUI()
        validateUI()
    }
    
    private func updateCurrencyUI() {
        editTableController?.currencyTextField?.text = viewModel.selectedCurrencyName
        editTableController?.changeCurrencyIndicator?.isHidden = !canChangeCurrency
        editTableController?.expenseSourceAmountTextField?.currency = viewModel.selectedCurrency
        editTableController?.expenseSourceGoalAmountTextField?.currency = viewModel.selectedCurrency
    }
    
    private func updateGoalUI() {
        editTableController?.setTypeSwitch(hidden: !viewModel.isNew)
        editTableController?.setGoalAmount(hidden: !viewModel.isGoal)
        editTableController?.updateUI()
    }
    
    private func updateIconUI() {
        let placeholderName = viewModel.isGoal ? "wallet-goal-default-icon" : "wallet-default-icon"
        editTableController?.iconImageView.setImage(with: viewModel.selectedIconURL, placeholderName: placeholderName, renderingMode: .alwaysTemplate)
        editTableController?.iconImageView.tintColor = UIColor(red: 105 / 255.0, green: 145 / 255.0, blue: 250 / 255.0, alpha: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTableView",
            let viewController = segue.destination as? ExpenseSourceEditTableController {
            editTableController = viewController
            viewController.delegate = self
        }
    }
}

extension ExpenseSourceEditViewController {
    private func setupUI() {
        setupNavigationBar()
        loaderImageView.showLoader()
//        editTableController?.tableView.allowsSelection = canChangeCurrency
        guard viewModel.isNew else {
            setActivityIndicator(hidden: true)
            return
        }
        loadDefaultCurrency()
    }
    
    private func loadDefaultCurrency() {
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        _ = firstly {
                viewModel.loadDefaultCurrency()
            }.ensure {
                self.updateUI()
                self.setActivityIndicator(hidden: true)
                self.saveButton.isEnabled = true
            }
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = viewModel.isNew ? "Новый кошелек" : "Кошелек"
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        guard animated else {
            loaderImageView.isHidden = hidden
            return
        }
        UIView.transition(with: loaderImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.loaderImageView.isHidden = hidden
        })
    }
    
    private func setRemoveButton(hidden: Bool, animated: Bool = true) {
        guard animated else {
            removeButton.isHidden = hidden
            return
        }
        UIView.transition(with: removeButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.removeButton.isHidden = hidden
        })
    }
}

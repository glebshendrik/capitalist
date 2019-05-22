//
//  ExpenseCategoryEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 18/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String)
    func didUpdateExpenseCategory(with basketType: BasketType)
    func didRemoveExpenseCategory(with basketType: BasketType)
}

protocol ExpenseCategoryEditInputProtocol {
    func set(expenseCategory: ExpenseCategory)
    func set(basketType: BasketType)
    func set(delegate: ExpenseCategoryEditViewControllerDelegate?)
}

class ExpenseCategoryEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, ApplicationRouterDependantProtocol {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    var viewModel: ExpenseCategoryEditViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    
    private var delegate: ExpenseCategoryEditViewControllerDelegate?
    
    private var editTableController: ExpenseCategoryEditTableController?
    private var expenseCategoryName: String? {
        return editTableController?.expenseCategoryNameTextField?.text?.trimmed
    }
    private var expenseCategoryMonthlyPlanned: String? {
        return editTableController?.expenseCategoryMonthlyPlannedTextField?.text?.trimmed
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
        editTableController?.setRemoveButton(hidden: viewModel.isNew)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    private func save() {
        view.endEditing(true)
        editTableController?.showActivityIndicator()
        saveButton.isEnabled = false
        
        firstly {
            viewModel.saveExpenseCategory(with: self.expenseCategoryName,
                                          iconURL: self.selectedIconURL,
                                          monthlyPlanned: self.expenseCategoryMonthlyPlanned)
        }.done {
            self.close(completion: {
                if self.viewModel.isNew {
                    self.delegate?.didCreateExpenseCategory(with: self.viewModel.basketType!, name: self.expenseCategoryName!)
                }
                else {
                    self.delegate?.didUpdateExpenseCategory(with: self.viewModel.basketType!)
                }
            })
        }.catch { error in
            switch error {
            case ExpenseCategoryCreationError.validation(let validationResults):
                self.showCreateionValidationResults(validationResults)
            case ExpenseCategoryUpdatingError.validation(let validationResults):
                self.showUpdatingValidationResults(validationResults)
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении категории трат",
                                                  theme: .error)
            }
        }.finally {
            self.editTableController?.hideActivityIndicator()
            self.saveButton.isEnabled = true
        }
    }
    
    private func remove(deleteTransactions: Bool) {
        editTableController?.showActivityIndicator()
        
        firstly {
            viewModel.removeExpenseCategory(deleteTransactions: deleteTransactions)
        }.done {
            self.delegate?.didRemoveExpenseCategory(with: self.viewModel.basketType!)
            self.close()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении категории трат",
                                              theme: .error)
        }.finally {
            self.editTableController?.hideActivityIndicator()
        }
    }
    
    private func close(completion: (() -> Void)? = nil) {
        navigationController?.dismiss(animated: true, completion: completion)
    }
}

extension ExpenseCategoryEditViewController : ExpenseCategoryEditTableControllerDelegate {
    func didTapRemoveButton() {
        let alertController = UIAlertController(title: "Удалить категорию трат?",
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
    
    var canChangeCurrency: Bool {
        return viewModel.isNew
    }
    
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func didSelectIncomeSourceCurrency(currency: Currency) {
        update(incomeSourceCurrency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
    
    func update(incomeSourceCurrency: Currency) {
        viewModel.selectedIncomeSourceCurrency = incomeSourceCurrency
        updateIncomeSourceCurrencyUI()
    }
    
    var basketType: BasketType {
        return viewModel.basketType ?? .joy
    }
    
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
    
    func validationNeeded() {
        validateUI()
    }
    
    private func validateUI() {
//        let isFormValid = viewModel.isFormValid(with: expenseCategoryName,
//                                                iconURL: selectedIconURL,
//                                                monthlyPlanned: expenseCategoryMonthlyPlanned)
//        let invalidColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
//        let validColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
//        saveButton.isEnabled = isFormValid
//        saveButton.backgroundColor = isFormValid ? validColor : invalidColor
    }
    
    func didTapSetReminder() {
        showReminderScreen()
    }
    
    func showReminderScreen() {
        if  let reminderEditNavigationController = router.viewController(.ReminderEditNavigationController) as? UINavigationController,
            let reminderEditViewController = reminderEditNavigationController.topViewController as? ReminderEditViewController {
            
            reminderEditViewController.set(reminderViewModel: viewModel.reminderViewModel, delegate: self)
            
            present(reminderEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension ExpenseCategoryEditViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminderViewModel = reminderViewModel
        updateReminderUI()
    }
}

extension ExpenseCategoryEditViewController {
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func showCreateionValidationResults(_ validationResults: [ExpenseCategoryCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = creationValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func creationValidationMessageFor(key: ExpenseCategoryCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.name, .required):
            return "Укажите название"
        case (.monthlyPlannedCents, .required):
            return "Укажите сумму"
        case (.monthlyPlannedCents, .invalid):
            return "Некорректная сумма"
        case (_, _):
            return "Ошибка ввода"
        }
    }
    
    private func showUpdatingValidationResults(_ validationResults: [ExpenseCategoryUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = updatingValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func updatingValidationMessageFor(key: ExpenseCategoryUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.name, .required):
            return "Укажите название"
        case (.monthlyPlannedCents, .required):
            return "Укажите сумму"
        case (.monthlyPlannedCents, .invalid):
            return "Некорректная сумма"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

extension ExpenseCategoryEditViewController : ExpenseCategoryEditInputProtocol {
    func set(delegate: ExpenseCategoryEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseCategory: ExpenseCategory) {
        viewModel.set(expenseCategory: expenseCategory)
    }
    
    func set(basketType: BasketType) {
        viewModel.set(basketType: basketType)
    }
    
    private func updateUI() {
        editTableController?.expenseCategoryNameTextField?.text = viewModel.name
        editTableController?.expenseCategoryMonthlyPlannedTextField?.text = viewModel.monthlyPlanned
        updateCurrencyUI()
        updateIncomeSourceCurrencyUI()
        updateIconUI()
        updateReminderUI()
        validateUI()
    }
    
    private func updateReminderUI() {
        editTableController?.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        editTableController?.reminderLabel.text = viewModel.reminder
    }
    
    private func updateCurrencyUI() {
        editTableController?.currencyTextField?.text = viewModel.selectedCurrencyName
        editTableController?.changeCurrencyIndicator?.isHidden = !canChangeCurrency
        editTableController?.expenseCategoryMonthlyPlannedTextField?.currency = viewModel.selectedCurrency
    }
    
    private func updateIncomeSourceCurrencyUI() {
        editTableController?.incomeSourceCurrencyTextField?.text = viewModel.selectedIncomeSourceCurrencyName
        editTableController?.changeIncomeSourceCurrencyIndicator?.isHidden = !viewModel.canChangeIncomeSourceCurrency
        editTableController?.setIncomeSourceCurrency(hidden: !viewModel.canChangeIncomeSourceCurrency)
    }
    
    private func updateIconUI() {
        
        func defaultIconName() -> String {
            switch viewModel.basketType! {
            case .joy:
                return "joy-default-icon"
            case .risk:
                return "risk-default-icon"
            case .safe:
                return "safe-default-icon"
            }
        }
        
        editTableController?.iconImageView.setImage(with: viewModel.selectedIconURL, placeholderName: defaultIconName(), renderingMode: .alwaysTemplate)
        
        let joyColor = UIColor(red: 1, green: 0.85, blue: 0.27, alpha: 1)
        let riskColor = UIColor(red: 0.49, green: 0.52, blue: 1, alpha: 1)
        let safeColor = UIColor(red: 0.13, green: 0.86, blue: 0.27, alpha: 1)
        
        func basketColor() -> UIColor {
            switch viewModel.basketType! {
            case .joy:
                return joyColor
            case .risk:
                return riskColor
            case .safe:
                return safeColor
            }
        }
        
        editTableController?.iconImageView.tintColor = basketColor()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTableView",
            let viewController = segue.destination as? ExpenseCategoryEditTableController {
            editTableController = viewController
            viewController.delegate = self
        }
    }
}

extension ExpenseCategoryEditViewController {
    private func setupUI() {
        setupNavigationBar()
        guard viewModel.isNew else {
            editTableController?.hideActivityIndicator()
            return
        }
        loadDefaultCurrency()
    }
    
    private func loadDefaultCurrency() {
        editTableController?.showActivityIndicator()
        saveButton.isEnabled = false
        
        _ = firstly {
                viewModel.loadDefaultCurrency()
            }.ensure {
                self.updateUI()
                self.editTableController?.hideActivityIndicator()
                self.saveButton.isEnabled = true
            }
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = viewModel.isNew ? "Новая категория трат" : "Категория трат"
    }
}
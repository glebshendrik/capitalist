//
//  ExpenseSourceEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import StaticTableViewController

protocol ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource()
    func didUpdateExpenseSource()
    func didRemoveExpenseSource()
}

protocol ExpenseSourceEditInputProtocol {
    func set(expenseSource: ExpenseSource)
    func set(delegate: ExpenseSourceEditViewControllerDelegate?)
}

class ExpenseSourceEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, ApplicationRouterDependantProtocol {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    var viewModel: ExpenseSourceEditViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    
    private var delegate: ExpenseSourceEditViewControllerDelegate?
    
    private var editTableController: ExpenseSourceEditTableController?
    
    private var expenseSourceName: String? {
        return editTableController?.expenseSourceNameTextField?.text?.trimmed
    }
    
    private var expenseSourceAmount: String? {
        return editTableController?.expenseSourceAmountTextField?.text?.trimmed
    }
    
    private var expenseSourceCreditLimitAmount: String? {
        return editTableController?.creditLimitTextField?.text?.trimmed
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
            viewModel.saveExpenseSource(with: self.expenseSourceName,
                                        amount: self.expenseSourceAmount,
                                        iconURL: self.selectedIconURL,
                                        goalAmount: self.expenseSourceGoalAmount,
                                        creditLimit: self.expenseSourceCreditLimitAmount)
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
            self.editTableController?.hideActivityIndicator()
            self.saveButton.isEnabled = true
        }
    }
    
    private func remove(deleteTransactions: Bool) {
        editTableController?.showActivityIndicator()
        
        firstly {
            viewModel.removeExpenseSource(deleteTransactions: deleteTransactions)
        }.done {
            self.delegate?.didRemoveExpenseSource()
            self.close()
        }.catch { error in
            switch error {
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении кошелька",
                                                  theme: .error)
            }
            
        }.finally {
            self.editTableController?.hideActivityIndicator()
        }
    }
    
    private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ExpenseSourceEditViewController : ProvidersViewControllerDelegate, ProviderConnectionViewControllerDelegate, AccountsViewControllerDelegate {
    
    func didSelect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection) {
        viewModel.connect(accountViewModel: accountViewModel, providerConnection: providerConnection)
        
    }
    
    func showProviders() {
        if let providersViewController = router.viewController(.ProvidersViewController) as? ProvidersViewController {
            
            providersViewController.delegate = self
            slideUp(viewController: providersViewController)
        }
    }
    
    func didSelect(providerViewModel: ProviderViewModel) {
        setupProviderConnection(for: providerViewModel)
    }
    
    func setupProviderConnection(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: "Загрузка подключения к банку...")
        firstly {
            viewModel.loadProviderConnection(for: providerViewModel.id)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { providerConnection in
            self.showAccountsViewController(for: providerConnection)
        }.catch { error in
            if case BankConnectionError.providerConnectionNotFound = error {
                self.createSaltEdgeConnectSession(for: providerViewModel)
            } else {
                self.messagePresenterManager.show(navBarMessage: "Не удалось загрузить подключение к банку", theme: .error)
            }
        }
    }
    
    func showAccountsViewController(for providerConnection: ProviderConnection) {
        if let accountsViewController = router.viewController(Infrastructure.ViewController.AccountsViewController) as? AccountsViewController {
            
            accountsViewController.delegate = self
            accountsViewController.viewModel.providerConnection = providerConnection
            accountsViewController.viewModel.currencyCode = viewModel.isNew ? nil : viewModel.selectedCurrencyCode
            slideUp(viewController: accountsViewController)
        }
    }
    
    func createSaltEdgeConnectSession(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: "Подготовка подключения к банку...")
        firstly {
            viewModel.createBankConnectionSession(for: providerViewModel)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { providerViewModel in
            self.showProviderConnectionViewController(for: providerViewModel)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Не удалось создать подключение к банку", theme: .error)
        }
    }
    
    func showProviderConnectionViewController(for providerViewModel: ProviderViewModel) {
        if let providerConnectionViewController = router.viewController(Infrastructure.ViewController.ProviderConnectionViewController) as? ProviderConnectionViewController {
            
            providerConnectionViewController.delegate = self
            providerConnectionViewController.providerViewModel = providerViewModel
            navigationController?.present(providerConnectionViewController, animated: true, completion: nil)
        }
    }
    
    func didConnect(connectionId: String, connectionSecret: String, providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: "Создание подключения к банку...")
        firstly {
            viewModel.createProviderConnection(connectionId: connectionId, connectionSecret: connectionSecret, providerViewModel: providerViewModel)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { providerConnection in
            self.showAccountsViewController(for: providerConnection)
        }.catch { error in
            self.messagePresenterManager.show(navBarMessage: "Не удалось создать подключение к банку", theme: .error)
        }
    }
    
    func didNotConnect() {
        self.messagePresenterManager.show(navBarMessage: "Не удалось подключиться к банку", theme: .error)
    }
    
    func didNotConnect(with: Error) {
        self.messagePresenterManager.show(navBarMessage: "Не удалось подключиться к банку", theme: .error)
    }
}

extension ExpenseSourceEditViewController : ExpenseSourceEditTableControllerDelegate {
    
    func didTapBankButton() {
        if viewModel.accountConnected {
            viewModel.removeAccountConnection()
        } else {
            showProviders()
        }
    }
    
    func didChangeCreditLimit() {
        if let creditLimit = expenseSourceCreditLimitAmount,
            creditLimit.isNumeric,
            viewModel.isNew {
            editTableController?.expenseSourceAmountTextField.text = creditLimit
        }
    }
    
    func didTapRemoveButton() {
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
    
    var accountType: AccountType {
        return viewModel.accountType
    }
    
    var canChangeAmount: Bool {
        return viewModel.canChangeAmount
    }
    
    var canChangeCurrency: Bool {
        return viewModel.canChangeCurrency
    }
    
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
    
    func didSwitch(accountType: AccountType) {
        viewModel.accountType = accountType
        updateIconUI()
        updateTableUI()
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

extension ExpenseSourceEditViewController : ExpenseSourceEditInputProtocol {
    func set(delegate: ExpenseSourceEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(expenseSource: ExpenseSource) {
        viewModel.set(expenseSource: expenseSource)
    }
    
    private func updateUI() {
        updateTextFieldsUI()
        updateCurrencyUI()
        updateIconUI()
        updateBankButtonUI()
        updateTableUI(animated: false)
        validateUI()
    }
    
    private func updateTextFieldsUI() {
        editTableController?.expenseSourceNameTextField?.text = viewModel.name
        editTableController?.expenseSourceAmountTextField?.text = viewModel.amount
        editTableController?.expenseSourceGoalAmountTextField?.text = viewModel.goalAmount
        editTableController?.creditLimitTextField?.text = viewModel.creditLimit
        
        editTableController?.expenseSourceAmountTextField?.isUserInteractionEnabled = viewModel.canChangeAmount
    }
    
    private func updateCurrencyUI() {
        editTableController?.currencyTextField?.text = viewModel.selectedCurrencyName
        editTableController?.changeCurrencyIndicator?.isHidden = !canChangeCurrency
        editTableController?.expenseSourceAmountTextField?.currency = viewModel.selectedCurrency
        editTableController?.expenseSourceGoalAmountTextField?.currency = viewModel.selectedCurrency
        editTableController?.creditLimitTextField?.currency = viewModel.selectedCurrency
    }
    
    private func updateTableUI(animated: Bool = true) {
        editTableController?.setTypeSwitch(hidden: !viewModel.isNew, animated: animated, reload: false)
        editTableController?.setAmount(hidden: viewModel.amountHidden, animated: animated, reload: false)
        editTableController?.setGoalAmount(hidden: !viewModel.isGoal, animated: animated, reload: false)
        editTableController?.setCreditLimit(hidden: viewModel.creditLimitHidden, animated: animated, reload: false)        
        editTableController?.setBankButton(hidden: viewModel.bankButtonHidden, animated: animated, reload: false)
        editTableController?.updateTabsAppearence()
        editTableController?.reloadData(animated: animated)
    }
    
    private func updateBankButtonUI() {
        
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
        navigationItem.title = viewModel.isNew ? "Новый кошелек" : "Кошелек"
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
        case (.creditLimitCents, .required):
            return "Укажите кредитный лимит (0 для обычного кошелька)"
        case (.creditLimitCents, .invalid):
            return "Некорректный кредитный лимит (0 для обычного кошелька)"
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
        case (.creditLimitCents, .required):
            return "Укажите кредитный лимит (0 для обычного кошелька)"
        case (.creditLimitCents, .invalid):
            return "Некорректный кредитный лимит (0 для обычного кошелька)"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

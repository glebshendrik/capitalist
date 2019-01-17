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
    func didCreateExpenseCategory(with basketType: BasketType)
    func didUpdateExpenseCategory(with basketType: BasketType)
    func didRemoveExpenseCategory(with basketType: BasketType)
}

protocol ExpenseCategoryEditInputProtocol {
    func set(expenseCategory: ExpenseCategory)
    func set(basketType: BasketType)
    func set(delegate: ExpenseCategoryEditViewControllerDelegate?)
}

class ExpenseCategoryEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    var viewModel: ExpenseCategoryEditViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
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
        setActivityIndicator(hidden: true, animated: false)
        setRemoveButton(hidden: viewModel.isNew)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Удалить категорию трат?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.remove()
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
            viewModel.saveExpenseCategory(with: self.expenseCategoryName,
                                          iconURL: self.selectedIconURL,
                                          monthlyPlanned: self.expenseCategoryMonthlyPlanned)
        }.done {
            if self.viewModel.isNew {
                self.delegate?.didCreateExpenseCategory(with: self.viewModel.basketType!)
            }
            else {
                self.delegate?.didUpdateExpenseCategory(with: self.viewModel.basketType!)
            }
            self.close()
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
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
        }
    }
    
    private func remove() {
        setActivityIndicator(hidden: false)
        removeButton.isEnabled = false
        
        firstly {
            viewModel.removeExpenseCategory()
        }.done {
            self.delegate?.didRemoveExpenseCategory(with: self.viewModel.basketType!)
            self.close()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении категории трат",
                                              theme: .error)
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.removeButton.isEnabled = true
        }
    }
    
    private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ExpenseCategoryEditViewController : ExpenseCategoryEditTableControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
    
    func validationNeeded() {
        validateUI()
    }
    
    private func validateUI() {
        let isFormValid = viewModel.isFormValid(with: expenseCategoryName,
                                                iconURL: selectedIconURL,
                                                monthlyPlanned: expenseCategoryMonthlyPlanned)
        let invalidColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        let validColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        saveButton.isEnabled = isFormValid
        saveButton.backgroundColor = isFormValid ? validColor : invalidColor
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
        updateIconUI()
        validateUI()
    }
    
    private func updateIconUI() {
        editTableController?.iconImageView.setImage(with: viewModel.selectedIconURL, placeholderName: "wallet-icon")
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
        loaderImageView.showLoader()
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = viewModel.isNew ? "Новая категория трат" : "Категория трат"
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

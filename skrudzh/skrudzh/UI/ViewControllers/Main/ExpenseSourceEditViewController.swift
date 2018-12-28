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
    
    @IBOutlet weak var saveButton: UIButton!
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
    private var expenseSourceIconURL: URL? {
        return nil
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
        let alertController = UIAlertController(title: "Удалить источник трат?",
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
            viewModel.saveExpenseSource(with: self.expenseSourceName, amount: self.expenseSourceAmount, iconURL: self.expenseSourceIconURL)
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
                self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении источника трат",
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
            viewModel.removeExpenseSource()
        }.done {
            self.delegate?.didRemoveExpenseSource()
            self.close()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении источника трат",
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

extension ExpenseSourceEditViewController : ExpenseSourceEditTableControllerDelegate {
    func validationNeeded() {
        validateUI()
    }
    
    private func validateUI() {
        let isFormValid = viewModel.isFormValid(with: expenseSourceName, amount: expenseSourceAmount, iconURL: expenseSourceIconURL)
        let invalidColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        let validColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        saveButton.isEnabled = isFormValid
        saveButton.backgroundColor = isFormValid ? validColor : invalidColor
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
            return "Укажите сумму"
        case (.amountCents, .invalid):
            return "Некорректная сумма"
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
            return "Укажите сумму"
        case (.amountCents, .invalid):
            return "Некорректная сумма"
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
        // TODO: set icon
        validateUI()
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
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = viewModel.isNew ? "Новый источник трат" : "Источник трат"
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

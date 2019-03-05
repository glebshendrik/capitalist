//
//  IncomeSourceEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource()
    func didUpdateIncomeSource()
    func didRemoveIncomeSource()
}

protocol IncomeSourceEditInputProtocol {
    func set(incomeSource: IncomeSource)
    func set(delegate: IncomeSourceEditViewControllerDelegate?)
}

class IncomeSourceEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor

    var viewModel: IncomeSourceEditViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    private var delegate: IncomeSourceEditViewControllerDelegate?
    
    private var editTableController: IncomeSourceEditTableController?
    private var incomeSourceName: String? {
        return editTableController?.incomeSourceNameTextField?.text?.trimmed
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
        let alertController = UIAlertController(title: "Удалить источник доходов?",
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
        saveButton.isUserInteractionEnabled = false
        
        firstly {
            viewModel.saveIncomeSource(with: self.incomeSourceName)
        }.done {
            if self.viewModel.isNew {
                self.delegate?.didCreateIncomeSource()
            }
            else {
                self.delegate?.didUpdateIncomeSource()
            }
            self.close()
        }.catch { error in
            switch error {
            case IncomeSourceCreationError.validation(let validationResults):
                self.showCreateionValidationResults(validationResults)
            case IncomeSourceUpdatingError.validation(let validationResults):
                self.showUpdatingValidationResults(validationResults)
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка при сохранении источника доходов",
                                                  theme: .error)
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isUserInteractionEnabled = true
        }
    }
    
    private func remove() {
        setActivityIndicator(hidden: false)
        removeButton.isUserInteractionEnabled = false
        
        firstly {
            viewModel.removeIncomeSource()
        }.done {
            self.delegate?.didRemoveIncomeSource()
            self.close()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении источника доходов",
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

extension IncomeSourceEditViewController : IncomeSourceEditTableControllerDelegate {
    var canChangeCurrency: Bool {
        return viewModel.isNew
    }
    
    func validationNeeded() {
        validateUI()
    }
    
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        editTableController?.currencyTextField?.text = viewModel.selectedCurrencyName
    }
        
    private func validateUI() {
        let isFormValid = viewModel.isFormValid(with: incomeSourceName)
        let invalidColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        let validColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        saveButton.isUserInteractionEnabled = isFormValid
        saveButton.backgroundColor = isFormValid ? validColor : invalidColor
    }
}

extension IncomeSourceEditViewController {
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
    
    private func showCreateionValidationResults(_ validationResults: [IncomeSourceCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = creationValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func creationValidationMessageFor(key: IncomeSourceCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.name, .required):
            return "Укажите название"
        case (_, _):
            return "Ошибка ввода"
        }
    }
    
    private func showUpdatingValidationResults(_ validationResults: [IncomeSourceUpdatingForm.CodingKeys: [ValidationErrorReason]]) {
        
        for key in validationResults.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            for reason in validationResults[key] ?? [] {
                let message = updatingValidationMessageFor(key: key, reason: reason)
                messagePresenterManager.show(validationMessage: message)
            }
        }
    }
    
    private func updatingValidationMessageFor(key: IncomeSourceUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.name, .required):
            return "Укажите название"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}

extension IncomeSourceEditViewController : IncomeSourceEditInputProtocol {
    func set(delegate: IncomeSourceEditViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(incomeSource: IncomeSource) {
        viewModel.set(incomeSource: incomeSource)
    }
    
    private func updateUI() {
        editTableController?.incomeSourceNameTextField?.text = viewModel.name
        editTableController?.currencyTextField?.text = viewModel.selectedCurrencyName
        editTableController?.changeCurrencyIndicator?.isHidden = !canChangeCurrency
        validateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTableView",
            let viewController = segue.destination as? IncomeSourceEditTableController {
            editTableController = viewController
            viewController.delegate = self
        }
    }
}

extension IncomeSourceEditViewController {
    private func setupUI() {
        setupNavigationBar()
        loaderImageView.showLoader()
        editTableController?.tableView.allowsSelection = canChangeCurrency
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
        navigationItem.title = viewModel.isNew ? "Новый источник доходов" : "Источник доходов"
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

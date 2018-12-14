//
//  IncomeSourceEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import StaticDataTableViewController
import PromiseKit

protocol IncomeSourceEditViewControllerDelegate {
    func didCreate()
    func didUpdate()
    func didRemove()
}

protocol IncomeSourceEditInputProtocol {
    func set(incomeSource: IncomeSource)
    func set(delegate: IncomeSourceEditViewControllerDelegate?)
}

class IncomeSourceEditViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    @IBOutlet weak var incomeSourceNameTextField: UITextField!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var removeButton: UIButton!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor

    var viewModel: IncomeSourceEditViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    private var delegate: IncomeSourceEditViewControllerDelegate?
    
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
        remove()
    }
    
    private func save() {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        firstly {
            viewModel.saveIncomeSource(with: self.incomeSourceNameTextField.text?.trimmed)
        }.done {
            if self.viewModel.isNew {
                self.delegate?.didCreate()
            }
            else {
                self.delegate?.didUpdate()
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
            self.saveButton.isEnabled = true
        }
    }
    
    private func remove() {
        setActivityIndicator(hidden: false)
        removeButton.isEnabled = false
        
        firstly {
            viewModel.removeIncomeSource()
        }.done {
            self.delegate?.didRemove()
            self.close()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при удалении источника доходов",
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
        incomeSourceNameTextField.text = viewModel.name
    }
}

extension IncomeSourceEditViewController {
    private func setupUI() {
        setupNavigationBar()
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
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    private func setRemoveButton(hidden: Bool, animated: Bool = true) {
        cell(removeCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
}

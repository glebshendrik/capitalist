//
//  TransactionEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

class TransactionEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var editTableController: TransactionEditTableController?
    
    var viewModel: TransactionEditViewModel! { return nil }
    
    var amount: String? {
        return viewModel.needCurrencyExchange ? editTableController?.exchangeStartableAmountTextField.text : editTableController?.amountTextField.text
    }
    
    var convertedAmount: String? {
        return viewModel.needCurrencyExchange ? editTableController?.exchangeCompletableAmountTextField.text : amount
    }
    
    var comment: String? {
        return nil
//        return editTableController?.commentTextField.text
    }
    
    var gotAt: Date {
        return Date()
//        return editTableController?.datePicker.date
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
        setActivityIndicator(hidden: true)
    }
    
    
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        let alertController = UIAlertController(title: viewModel.removeQuestion,
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
    
    func isFormValid(amount: String?,
                     convertedAmount: String?,
                     comment: String?,
                     gotAt: Date?) -> Bool {
        return false
    }
    
    func savePromise(amount: String?,
                     convertedAmount: String?,
                     comment: String?,
                     gotAt: Date?) -> Promise<Void> {
        return Promise.value(())
    }
    
    func savePromiseResolved() {
    }
    
    func catchSaveError(_ error: Error) {
    }
    
    func removePromise() -> Promise<Void> {
        return Promise.value(())
    }
    
    func removePromiseResolved() {
        
    }
    
    func catchRemoveError(_ error: Error) {
        
    }
    
    private func save() {
        view.endEditing(true)
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        firstly {
            savePromise(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
        }.done {
            self.savePromiseResolved()
            self.close()
        }.catch { error in
            self.catchSaveError(error)
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
        }
    }
    
    private func remove() {
        setActivityIndicator(hidden: false)
        removeButton.isEnabled = false
        
        firstly {
            removePromise()
        }.done {
            self.removePromiseResolved()
            self.close()
        }.catch { error in
            self.catchRemoveError(error)
            
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.removeButton.isEnabled = true
        }
    }
    
    private func loadExchangeRate() {
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        firstly {
            viewModel.loadExchangeRate()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при загрузке курса валют",
                                              theme: .error)
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
        }
    }
    
    private func close() {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension TransactionEditViewController : TransactionEditTableControllerDelegate {
    func didChangeAmount() {
        editTableController?.exchangeCompletableAmountTextField.text = viewModel.convert(amount: editTableController?.exchangeStartableAmountTextField.text)
    }
    
    private func setupUI() {
        setupNavigationBar()
        loaderImageView.showLoader()
        guard viewModel.isNew else {
            setActivityIndicator(hidden: true)
            return
        }
        if viewModel.needCurrencyExchange {
            loadExchangeRate()
        }
    }
        
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = viewModel.title
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
    
    private func updateUI() {
        // startable
        editTableController?.startableNameTextField.text = viewModel.startableName
        editTableController?.startableBalanceLabel.text = viewModel.startableAmount
        editTableController?.startableIconImageView.setImage(with: viewModel.startableIconURL,
                                                             placeholderName: viewModel.startableIconDefaultImageName,
                                                             renderingMode: .alwaysTemplate)
        editTableController?.startableNameTextField.selectedTitle = viewModel.startableTitle
        editTableController?.startableNameTextField.placeholder = viewModel.startableTitle
        
        // completable
        editTableController?.completableNameTextField.text = viewModel.completableName
        editTableController?.completableBalanceLabel.text = viewModel.completableAmount
        editTableController?.completableIconImageView.setImage(with: viewModel.completableIconURL,
                                                               placeholderName: viewModel.completableIconDefaultImageName,
                                                               renderingMode: .alwaysTemplate)
        editTableController?.completableNameTextField.selectedTitle = viewModel.completableTitle
        editTableController?.completableNameTextField.placeholder = viewModel.completableTitle
        
        // amount
        editTableController?.amountTextField.text = viewModel.amount
        editTableController?.amountTextField.selectedTitle = viewModel.completableAmountTitle
        editTableController?.amountTextField.placeholder = viewModel.completableAmountTitle
        editTableController?.amountCurrencyLabel.text = viewModel.completableCurrencyCode
        editTableController?.amountTextField?.currency = viewModel.startableCurrency
        
        // exchange amounts
        editTableController?.exchangeStartableAmountTextField.text = viewModel.amount
        editTableController?.exchangeStartableAmountTextField.currency = viewModel.startableCurrency
        editTableController?.exchangeStartableAmountCurrencyLabel.text = viewModel.startableCurrencyCode
        
        editTableController?.exchangeCompletableAmountTextField.text = viewModel.convertedAmount
        editTableController?.exchangeCompletableAmountTextField.currency = viewModel.completableCurrency
        editTableController?.exchangeCompletableAmountCurrencyLabel.text = viewModel.completableCurrencyCode
        
        editTableController?.update(needsExchange: viewModel.needCurrencyExchange)
        
        validateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTableView",
            let viewController = segue.destination as? TransactionEditTableController {
            editTableController = viewController
            viewController.delegate = self
        }
    }
    
    func validationNeeded() {
        validateUI()
    }
    
    func didSaveAtYesterday() {
        save()
    }
    
    func needsFirstResponder() {
        if viewModel.needCurrencyExchange {
            editTableController?.exchangeStartableAmountTextField.becomeFirstResponder()
        } else {
            editTableController?.amountTextField.becomeFirstResponder()
        }
    }
    
    private func validateUI() {
//        let invalidColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
//        let validColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        saveButton.isEnabled = self.isFormValid(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
//        saveButton.backgroundColor = isFormValid ? validColor : invalidColor
    }
    
    
}

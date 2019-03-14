//
//  TransactionEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftDate

class TransactionEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    var editTableController: TransactionEditTableController?
    
    var viewModel: TransactionEditViewModel! { return nil }
    
    var amount: String? {
        return viewModel.needCurrencyExchange ? editTableController?.exchangeStartableAmountTextField.text : editTableController?.amountTextField.text
    }
    
    var convertedAmount: String? {
        return viewModel.needCurrencyExchange ? editTableController?.exchangeCompletableAmountTextField.text : amount
    }
    
    var comment: String? {
        return viewModel.comment
    }
    
    var gotAt: Date {
        return viewModel.gotAt ?? Date()
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
        removeButton.isUserInteractionEnabled = false
        
        firstly {
            removePromise()
        }.done {
            self.removePromiseResolved()
            self.close()
        }.catch { error in
            self.catchRemoveError(error)
            
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.removeButton.isUserInteractionEnabled = true
        }
    }
    
    func loadExchangeRate() {
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
            self.updateUI()
        }
    }
    
    private func close() {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension TransactionEditViewController : TransactionEditTableControllerDelegate {
    
    @objc func didTapStartable() {
        
    }
    
    @objc func didTapCompletable() {
        
    }
    
    func didChangeAmount() {
        editTableController?.exchangeCompletableAmountTextField.text = viewModel.convert(amount: editTableController?.exchangeStartableAmountTextField.text)
    }
    
    private func setupUI() {
        setupNavigationBar()
        loaderImageView.showLoader()
        setActivityIndicator(hidden: true)
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
    
    func updateUI() {
        updateStartableUI()
        updateCompletableUI()
        updateAmountUI()
        updateExchangeAmountsUI()
        validateUI()
    }
    
    private func updateStartableUI() {
        editTableController?.startableNameTextField.text = viewModel.startableName
        editTableController?.startableBalanceLabel.text = viewModel.startableAmount
        editTableController?.startableIconImageView.setImage(with: viewModel.startableIconURL,
                                                             placeholderName: viewModel.startableIconDefaultImageName,
                                                             renderingMode: .alwaysTemplate)
        editTableController?.startableNameTextField.selectedTitle = viewModel.startableTitle
        editTableController?.startableNameTextField.placeholder = viewModel.startableTitle
    }
    
    private func updateCompletableUI() {
        editTableController?.completableNameTextField.text = viewModel.completableName
        editTableController?.completableBalanceLabel.text = viewModel.completableAmount
        editTableController?.completableIconImageView.setImage(with: viewModel.completableIconURL,
                                                               placeholderName: viewModel.completableIconDefaultImageName,
                                                               renderingMode: .alwaysTemplate)
        editTableController?.completableNameTextField.selectedTitle = viewModel.completableTitle
        editTableController?.completableNameTextField.placeholder = viewModel.completableTitle
    }
    
    private func updateAmountUI() {
        editTableController?.amountTextField.text = viewModel.amount
        editTableController?.amountTextField.selectedTitle = viewModel.completableAmountTitle
        editTableController?.amountTextField.placeholder = viewModel.completableAmountTitle
        editTableController?.amountCurrencyLabel.text = viewModel.completableCurrencyCode
        editTableController?.amountTextField?.currency = viewModel.startableCurrency
    }
    
    private func updateExchangeAmountsUI() {
        editTableController?.exchangeStartableAmountTextField.text = viewModel.amount
        editTableController?.exchangeStartableAmountTextField.currency = viewModel.startableCurrency
        editTableController?.exchangeStartableAmountCurrencyLabel.text = viewModel.startableCurrencyCode
        
        editTableController?.exchangeCompletableAmountTextField.text = viewModel.convertedAmount
        editTableController?.exchangeCompletableAmountTextField.currency = viewModel.completableCurrency
        editTableController?.exchangeCompletableAmountCurrencyLabel.text = viewModel.completableCurrencyCode
        
        editTableController?.update(needsExchange: viewModel.needCurrencyExchange)
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
        didSelect(date: Date() - 1.days)
        save()
    }
    
    func needsFirstResponder() {
        if viewModel.needCurrencyExchange {
            editTableController?.exchangeStartableAmountTextField.becomeFirstResponder()
        } else {
            editTableController?.amountTextField.becomeFirstResponder()
        }
    }
    
    func didTapComment() {
        let commentController = CommentViewController()
        commentController.set(delegate: self)
        commentController.set(comment: comment)
        commentController.modalPresentationStyle = .custom
        present(commentController, animated: true, completion: nil)
    }
    
    func didTapCalendar() {
        let datePickerController = DatePickerViewController()
        datePickerController.set(delegate: self)
        datePickerController.set(date: gotAt)
        datePickerController.modalPresentationStyle = .custom
        present(datePickerController, animated: true, completion: nil)
    }
    
    private func validateUI() {
//        saveButton.isEnabled = self.isFormValid(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
}

extension TransactionEditViewController : CommentViewControllerDelegate {
    func didSave(comment: String?) {
        viewModel.comment = comment
    }
}

extension TransactionEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        viewModel.gotAt = date
    }
}

extension TransactionEditViewController : IncomeSourceSelectViewControllerDelegate {
    
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel) {
        viewModel.startable = incomeSourceViewModel
        updateUI()
        loadExchangeRate()
    }
    
}

extension TransactionEditViewController : ExpenseSourceSelectViewControllerDelegate {
    func didSelect(startableExpenseSourceViewModel: ExpenseSourceViewModel) {
        viewModel.startable = startableExpenseSourceViewModel
        updateUI()
        loadExchangeRate()
    }
    
    func didSelect(completableExpenseSourceViewModel: ExpenseSourceViewModel) {
        viewModel.completable = completableExpenseSourceViewModel
        updateUI()
        loadExchangeRate()
    }
}

extension TransactionEditViewController : ExpenseCategorySelectViewControllerDelegate {
    
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel) {
        viewModel.completable = expenseCategoryViewModel
        updateUI()
        loadExchangeRate()
    }
    
}

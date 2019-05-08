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
        if !viewModel.needCurrencyExchange {
            return editTableController?.amountTextField.text
        }
        
        if let text = editTableController?.exchangeStartableAmountTextField.text?.trimmed,
            !text.isEmpty {
            return text
        }
        
        guard let convertedAmountText = editTableController?.exchangeCompletableAmountTextField.text?.trimmed,
            !convertedAmountText.isEmpty else { return nil }
        
        return viewModel.convert(amount: convertedAmountText, isForwardConversion: false)
    }
    
    var convertedAmount: String? {
        if !viewModel.needCurrencyExchange {
            return editTableController?.amountTextField.text
        }
        
        if let text = editTableController?.exchangeCompletableAmountTextField.text?.trimmed,
            !text.isEmpty {
            return text
        }
        
        guard let amountText = editTableController?.exchangeStartableAmountTextField.text?.trimmed,
            !amountText.isEmpty else { return nil }
        
        return viewModel.convert(amount: amountText, isForwardConversion: true)
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
        loadData()
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
    
    func loadData() {
        setActivityIndicator(hidden: false)
        saveButton.isEnabled = false
        
        firstly {
            viewModel.loadData()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при загрузке данных",
                                              theme: .error)
            self.close()
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.saveButton.isEnabled = true
            self.updateUI()
            self.needsFirstResponder()
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
        editTableController?.exchangeCompletableAmountTextField.placeholder = viewModel.convert(amount: editTableController?.exchangeStartableAmountTextField.text, isForwardConversion: true) ?? "Сумма"
    }
    
    func didChangeConvertedAmount() {
        editTableController?.exchangeStartableAmountTextField.placeholder = viewModel.convert(amount: editTableController?.exchangeCompletableAmountTextField.text, isForwardConversion: false) ?? "Сумма"
    }
    
    private func setupUI() {
        setupNavigationBar()
        loaderImageView.showLoader()
        setActivityIndicator(hidden: true)
    }
        
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
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
        updateTitleUI()
        updateStartableUI()
        updateCompletableUI()
        updateAmountUI()
        updateExchangeAmountsUI()
        updateToolbarUI()
        updateDebtUI()
        validateUI()
    }
    
    private func updateTitleUI() {
        navigationItem.title = viewModel.title
    }
    
    private func updateToolbarUI() {
        
        let commentImage = viewModel.hasComment ? #imageLiteral(resourceName: "selected-comment-icon") : #imageLiteral(resourceName: "comment-icon")
        
        let calendarImage = viewModel.hasGotAtDate ? #imageLiteral(resourceName: "selected-calendar-icon") : #imageLiteral(resourceName: "calendar-icon")
        
        UIView.transition(with: removeButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.editTableController?.commentButton.setImage(commentImage.withRenderingMode(.alwaysTemplate), for: .normal)
            self.editTableController?.calendarButton.setImage(calendarImage.withRenderingMode(.alwaysTemplate), for: .normal)
        })
        
    }
    
    @objc func updateDebtUI() {
        editTableController?.setDebtCell(hidden: !viewModel.isDebtOrLoan)
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
        commentController.set(comment: comment, placeholder: "Комментарий")
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
    
    @objc func didTapWhom() {
        
    }
    
    @objc func didTapBorrowedTill() {
        
    }
    
    private func validateUI() {
//        saveButton.isEnabled = self.isFormValid(amount: amount, convertedAmount: convertedAmount, comment: comment, gotAt: gotAt)
    }
}

extension TransactionEditViewController : CommentViewControllerDelegate {
    func didSave(comment: String?) {
        viewModel.comment = comment?.trimmed
        updateToolbarUI()
    }
}

extension TransactionEditViewController : DatePickerViewControllerDelegate {
    func didSelect(date: Date?) {
        viewModel.gotAt = date
        updateToolbarUI()
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

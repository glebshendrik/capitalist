//
//  TransactionEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension TransactionEditViewController : TransactionEditTableControllerDelegate {
    func didTapRemoveButton() {
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
    
    func didChangeAmount() {
        editTableController?.exchangeCompletableAmountTextField.placeholder = viewModel.convert(amount: editTableController?.exchangeStartableAmountTextField.text, isForwardConversion: true) ?? "Сумма"
    }
    
    func didChangeConvertedAmount() {
        editTableController?.exchangeStartableAmountTextField.placeholder = viewModel.convert(amount: editTableController?.exchangeCompletableAmountTextField.text, isForwardConversion: false) ?? "Сумма"
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
    
    @objc func didTapStartable() {
        
    }
    
    @objc func didTapCompletable() {
        
    }
    
    @objc func didTapWhom() {
        
    }
    
    @objc func didTapBorrowedTill() {
        
    }
    
    @objc func didChange(includedInBalance: Bool) {
        
    }
    
    @objc func didTapReturn() {
        
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

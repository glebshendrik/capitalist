//
//  ExpenseSourceEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ExpenseSourceEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
}

extension ExpenseSourceEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
}


extension ExpenseSourceEditViewController : ExpenseSourceEditTableControllerDelegate {
    func didTap(accountType: AccountType) {
        viewModel.accountType = accountType
        updateIconUI()
        updateTableUI()
    }
    
    func didTapIcon() {
        guard let iconsViewController = router.viewController(.IconsViewController) as? IconsViewController else { return }
        
        iconsViewController.set(iconCategory: viewModel.iconCategory)
        iconsViewController.set(delegate: self)
        navigationController?.pushViewController(iconsViewController)
    }
    
    func didTapCurrency() {
        guard   viewModel.canChangeCurrency,
            let currenciesViewController = router.viewController(.CurrenciesViewController) as? CurrenciesViewController else { return }
        
        currenciesViewController.set(delegate: self)
        navigationController?.pushViewController(currenciesViewController)
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(amount: String?) {
        viewModel.amount = amount
    }
    
    func didChange(creditLimit: String?) {
        viewModel.creditLimit = creditLimit
        updateTextFieldsUI()
    }
    
    func didChange(goalAmount: String?) {
        viewModel.goalAmount = goalAmount
    }
        
    func didTapBankButton() {
        if viewModel.accountConnected {
            removeAccountConnection()
        } else {
            showProviders()
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
                                    self.deleteTransactions = false
                                    self.remove()
        })
        
        alertController.addAction(title: "Удалить вместе с транзакциями",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.deleteTransactions = true
                                    self.remove()
        })
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
}

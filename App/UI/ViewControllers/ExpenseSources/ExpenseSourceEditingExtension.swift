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

extension ExpenseSourceEditViewController : CardTypesViewControllerDelegate {
    func didSelect(cardType: CardType?) {
        viewModel.selectedCardType = cardType
        updateCardTypeUI()
    }
}

extension ExpenseSourceEditViewController : ExpenseSourceEditTableControllerDelegate {
    func didTapCardType() {
        modal(factory.cardTypesViewController(delegate: self))
    }
    
    func didAppear() {
        focusFirstEmptyField()
    }
    
    func didTapIcon() {
        guard viewModel.canChangeIcon else { return }
        modal(factory.iconsViewController(delegate: self, iconCategory: viewModel.iconCategory))
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        modal(factory.currenciesViewController(delegate: self))
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
                
    func didTapSave() {
        save()
    }
}

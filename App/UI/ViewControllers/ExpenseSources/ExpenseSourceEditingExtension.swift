//
//  ExpenseSourceEditingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PopupDialog

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
    
    func didTapBankButton() {
        toggleConnectionFlow(providerCodes: viewModel.providerCodes)
    }
}

extension ExpenseSourceEditViewController : TransactionableExamplesViewControllerDelegate {
    func didSelect(exampleViewModel: TransactionableExampleViewModel) {
        viewModel.set(example: exampleViewModel)
        suggestBankConnection()
    }
    
    func suggestBankConnection() {
        guard
            viewModel.connectable
        else {
            updateUI()
            return
        }
        
        let alertTitle = NSLocalizedString("Вы можете воспользоваться функцией интеграции с банками", comment: "")
        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Подключиться к банку", comment: ""),
                                                      style: .default,
                                                      handler: { _ in
                                                        self.updateUI()
                                                        self.toggleConnectionFlow(providerCodes: self.viewModel.providerCodes)
                                                      }),
                                        UIAlertAction(title: NSLocalizedString("Ввести данные вручную", comment: ""),
                                                      style: .default,
                                                      handler: { _ in
                                                        self.updateUI()
                                                      })]
        sheet(title: alertTitle,
              actions: actions,
              preferredStyle: .alert,
              addCancel: false)
    }
}

//
//  SettingsViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 07/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class SettingsViewController : FormEditViewController {    
    var viewModel: SettingsViewModel!
    var tableController: SettingsTableController!
    
    override var shouldLoadData: Bool { return true }
    override var formTitle: String { return NSLocalizedString("Настройки", comment: "Настройки") }
    override var loadErrorMessage: String? { return NSLocalizedString("Возникла проблема при загрузке настроек", comment: "Возникла проблема при загрузке настроек") }
    
    override func setup(tableController: FormFieldsTableViewController) {
        self.tableController = tableController as? SettingsTableController
        self.tableController.delegate = self
    }
    
    override func loadDataPromise() -> Promise<Void> {
        return viewModel.loadData()
    }
    
    override func updateUI() {
        super.updateUI()
        updateCurrencyUI()
        updatePeriodUI()
        updateSoundsUI()
        updateLanguageUI()
        updateVerificationUI()
        updateDragSpeedUI()
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.currency
    }
    
    func updatePeriodUI() {
        tableController.periodField.text = viewModel.period
    }
    
    func updateSoundsUI() {
        tableController.soundsSwitchField.value = viewModel.soundsEnabled
    }
    
    func updateLanguageUI() {
        tableController.languageField.text = viewModel.language
    }
    
    func updateVerificationUI() {
        tableController.verificationSwitchField.value = viewModel.verificationEnabled
        tableController.set(cell: tableController.verificationSwitchCell, hidden: viewModel.verificationHidden, animated: false, reload: true)
    }
    
    func updateDragSpeedUI() {
        tableController.transactionDragSpeedField.minimumValue = 50
        tableController.transactionDragSpeedField.maximumValue = 500
        tableController.transactionDragSpeedField.step = 25
        tableController.transactionDragSpeedField.value = Float(viewModel.fastGesturePressDurationMilliseconds)
        tableController.transactionDragSpeedField.valueFormatter = { value in
            return "\(Int(value)) \(NSLocalizedString("мс", comment: "мс"))"
        }
    }
}

extension SettingsViewController : SettingsTableControllerDelegate {
    func didChange(fastGesturePressDurationMilliseconds: Int) {
        viewModel.set(fastGesturePressDurationMilliseconds: fastGesturePressDurationMilliseconds)
        updateDragSpeedUI()
    }
    
    func didTapLanguage() {
        guard   let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
    
    func didChange(verificationEnabled: Bool) {
        _ = firstly {
                viewModel.setVerification(enabled: verificationEnabled)
            }.ensure {
                self.updateVerificationUI()
            }
    }
    
    func didChange(soundsOn: Bool) {
        viewModel.setSounds(enabled: soundsOn)
    }
    
    func didAppear() {
        loadData()
    }
    
    func didTapCurrency() {
        modal(factory.currenciesViewController(delegate: self))
    }
    
    func didTapPeriod() {
        showPeriodsSheet()
    }
    
    func didRefresh() {
        loadData()
    }
}

extension SettingsViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        dirtyUpdate(currency: currency)
        operationStarted()
        
        firstly {
            viewModel.update(currency: currency)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Возникла проблема при обновлении валюты", comment: "Возникла проблема при обновлении валюты"), theme: .error)
            
        }.finally {
            self.operationFinished()
            self.updateUI()
        }
    }
    
    private func dirtyUpdate(currency: Currency) {
        tableController.currencyField.text = currency.translatedName
    }
}

extension SettingsViewController {
    func update(period: AccountingPeriod) {
        dirtyUpdate(period: period)
        operationStarted()
        
        firstly {
            viewModel.update(period: period)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Возникла проблема при обновлении периода", comment: "Возникла проблема при обновлении периода"), theme: .error)
            
        }.finally {
            self.operationFinished()
            self.updateUI()
        }
    }
    
    private func dirtyUpdate(period: AccountingPeriod) {
        tableController.periodField.text = period.title
    }
    
    private func showPeriodsSheet() {
        let periods: [AccountingPeriod] = [.week, .month, .quarter, .year]
        let actions = periods.map { period in
            return UIAlertAction(title: period.title,
                                 style: .default,
                                 handler: { _ in
                                    self.update(period: period)
            })
        }
        
        sheet(title: nil, actions: actions)
    }
}

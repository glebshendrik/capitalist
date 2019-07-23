//
//  ExpenseSourceEditBankConnectionExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension ExpenseSourceEditViewController : ProvidersViewControllerDelegate, ProviderConnectionViewControllerDelegate, AccountsViewControllerDelegate {
    
    func didSelect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection) {
        viewModel.connect(accountViewModel: accountViewModel, providerConnection: providerConnection)
        updateUI()
    }
    
    func removeAccountConnection() {
        viewModel.removeAccountConnection()
        updateUI()
    }
    
    func showProviders() {
        if let providersViewController = router.viewController(.ProvidersViewController) as? ProvidersViewController {
            
            providersViewController.delegate = self
            slideUp(viewController: providersViewController)
        }
    }
    
    func didSelect(providerViewModel: ProviderViewModel) {
        setupProviderConnection(for: providerViewModel)
    }
    
    func setupProviderConnection(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: "Загрузка подключения к банку...")
        firstly {
            viewModel.loadProviderConnection(for: providerViewModel.id)
            }.ensure {
                self.messagePresenterManager.dismissHUD()
            }.get { providerConnection in
                self.showAccountsViewController(for: providerConnection)
            }.catch { error in
                if case BankConnectionError.providerConnectionNotFound = error {
                    self.createSaltEdgeConnectSession(for: providerViewModel)
                } else {
                    self.messagePresenterManager.show(navBarMessage: "Не удалось загрузить подключение к банку", theme: .error)
                }
        }
    }
    
    func showAccountsViewController(for providerConnection: ProviderConnection) {
        if let accountsViewController = router.viewController(Infrastructure.ViewController.AccountsViewController) as? AccountsViewController {
            
            accountsViewController.delegate = self
            accountsViewController.viewModel.providerConnection = providerConnection
            accountsViewController.viewModel.currencyCode = viewModel.isNew ? nil : viewModel.selectedCurrencyCode
            slideUp(viewController: accountsViewController)
        }
    }
    
    func createSaltEdgeConnectSession(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: "Подготовка подключения к банку...")
        firstly {
            viewModel.createBankConnectionSession(for: providerViewModel)
            }.ensure {
                self.messagePresenterManager.dismissHUD()
            }.get { providerViewModel in
                self.showProviderConnectionViewController(for: providerViewModel)
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Не удалось создать подключение к банку", theme: .error)
        }
    }
    
    func showProviderConnectionViewController(for providerViewModel: ProviderViewModel) {
        if let providerConnectionViewController = router.viewController(Infrastructure.ViewController.ProviderConnectionViewController) as? ProviderConnectionViewController {
            
            providerConnectionViewController.delegate = self
            providerConnectionViewController.providerViewModel = providerViewModel
            navigationController?.present(providerConnectionViewController, animated: true, completion: nil)
        }
    }
    
    func didConnect(connectionId: String, connectionSecret: String, providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: "Создание подключения к банку...")
        firstly {
            viewModel.createProviderConnection(connectionId: connectionId, connectionSecret: connectionSecret, providerViewModel: providerViewModel)
            }.ensure {
                self.messagePresenterManager.dismissHUD()
            }.get { providerConnection in
                self.showAccountsViewController(for: providerConnection)
            }.catch { error in
                self.messagePresenterManager.show(navBarMessage: "Не удалось создать подключение к банку", theme: .error)
        }
    }
    
    func didNotConnect() {
        self.messagePresenterManager.show(navBarMessage: "Не удалось подключиться к банку", theme: .error)
    }
    
    func didNotConnect(with: Error) {
        self.messagePresenterManager.show(navBarMessage: "Не удалось подключиться к банку", theme: .error)
    }
}

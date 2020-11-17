//
//  BankConnectableProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 07.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyBeaver

protocol BankConnectableProtocol : UIFactoryDependantProtocol,
                                            UIMessagePresenterManagerDependantProtocol,
                                            ProvidersViewControllerDelegate,
                                            ConnectionViewControllerDelegate,
                                            AccountsViewControllerDelegate,
                                            ExperimentalBankFeatureViewControllerDelegate {
    
    var bankConnectableViewModel: BankConnectableViewModel! { get }
    
    func toggleConnectionFlow(providerCodes: [String]?)
    func setupConnection()
    func showAccounts()
    
    func refreshData()
    func save()
}

extension BankConnectableProtocol {
    func toggleConnectionFlow(providerCodes: [String]?) {
        guard
            !bankConnectableViewModel.connectionConnected
        else {
            disconnectAccount()
            return
        }
        
        guard
            bankConnectableViewModel.canConnectBank
        else {
            modal(factory.subscriptionNavigationViewController(requiredPlans: [.platinum]))
            return
        }
        
        showProviders(codes: providerCodes ?? [])
    }
}

extension BankConnectableProtocol {
    private func showProviders(codes: [String]) {
        if codes.count == 1,
           let code = codes.first {
            
            messagePresenterManager.showHUD(with: NSLocalizedString("Загрузка подключения к банку...",
                                                                    comment: "Загрузка подключения к банку..."))
            firstly {
                bankConnectableViewModel.loadProvider(code: code)
            }.ensure {
                self.dismissHUD()
            }.get { provider in
                self.didSelectProvider(provider)
            }.catch { error in
                self.modal(self.factory.providersViewController(delegate: self, codes: []))
            }
        }
        else {
            modal(factory.providersViewController(delegate: self, codes: codes))
        }        
    }
    
    func didSelectProvider(_ providerViewModel: ProviderViewModel) {
        bankConnectableViewModel.providerViewModel = providerViewModel
        if !UIFlowManager.reach(point: .bankExperimentalFeature) {
            showExperimentalFeature()
        }
        else {
            setupConnection()
        }        
    }
}

extension BankConnectableProtocol {
    func showExperimentalFeature() {
        modal(factory.experimentalBankFeatureViewController(delegate: self))        
    }
    
    func didChooseUseFeature() {
//        bankConnectableViewModel.shouldUseExperimentalFeature = true
        setupConnection()
    }
    
    func didChooseDontUseFeature() {
//        bankConnectableViewModel.shouldUseExperimentalFeature = false
//        setupConnection()
    }
}

extension BankConnectableProtocol {
    func setupConnection() {        
        messagePresenterManager.showHUD(with: NSLocalizedString("Загрузка подключения к банку...",
                                                                comment: "Загрузка подключения к банку..."))        
        firstly {
            bankConnectableViewModel.loadConnection()
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { _ in
            self.updateConnection()
            self.bankConnectableViewModel.hasActionIntent = false
        }.catch { error in
            self.bankConnectableViewModel.hasActionIntent = false
            if case BankConnectionError.connectionNotFound = error {
                self.showConnectionSession(type: .creating)
            } else {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось загрузить подключение к банку",
                                                                                   comment: "Не удалось загрузить подключение к банку"),
                                                  theme: .error)
            }
        }
    }
    
    func updateConnection() {
        guard
            let connection = bankConnectableViewModel.connection
        else {
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
                                                                               comment: "Не удалось подключиться к банку"),
                                              theme: .error)
            return
        }
        switch connection.status {
            case .active:
                if !bankConnectableViewModel.connectionConnected {
                    connectConnection(connection)
                }
                else if connection.reconnectNeeded {
                    guard
                        let stage = connection.lastStage,
                        !stage.isInteractive
                    else {
                        refreshData()
                        return
                    }
                    guard
                        !bankConnectableViewModel.hasActionIntent
                    else {
                        refreshData()
                        return
                    }
                    if let session = connection.session,
                       session.expiresAt.isInFuture {                        
                        showConnectionViewController(session: session)
                    }
                    else {
                        showConnectionSession(type: connection.isConnectedSuccessfully
                                                ? .refreshing
                                                : .reconnecting)
                    }
                }                
                else {
                    showAccounts()
                }
                
               
            case .inactive:
                self.showConnectionSession(type: .reconnecting)
            case .deleted:
                self.showConnectionSession(type: .creating)
        }
    }
    
    func connectConnection(_ connection: Connection) {
        guard
            !bankConnectableViewModel.connectionConnected
        else {
            refreshData()
            return
        }
        bankConnectableViewModel.connectConnection(connection)
        programmaticallySave()
    }
    
    func connectAccount(_ account: AccountViewModel) {
        bankConnectableViewModel.connectAccount(account)
        programmaticallySave()
    }
    
    func disconnectAccount() {
        bankConnectableViewModel.disconnectAccount()
        programmaticallySave()
    }
    
    private func programmaticallySave() {
        bankConnectableViewModel.intentToSave = true
        save()
    }
}

extension BankConnectableProtocol {
    func showConnectionSession(type: ConnectionSessionType) {
        messagePresenterManager.showHUD(with: NSLocalizedString("Подготовка подключения к банку...",
                                                                comment: "Подготовка подключения к банку..."))
        
        func connectionSession() -> Promise<ConnectionSession> {
            switch type {
                case .creating:
                    return bankConnectableViewModel.creatingConnectionSession()
                case .refreshing:
                    return bankConnectableViewModel.refreshingConnectionSession()
                case .reconnecting:
                    return bankConnectableViewModel.reconnectingConnectionSession()
            }
        }
        
        firstly {
            connectionSession()
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { session in
            self.showConnectionViewController(session: session)
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку",
                                                                               comment: "Не удалось создать подключение к банку"),
                                              theme: .error)
        }
    }
    
    private func showConnectionViewController(session: ConnectionSession) {
        let connectionViewController = factory.connectionViewController(delegate: self,
                                                                        providerViewModel: bankConnectableViewModel.providerViewModel,
                                                                        connection: bankConnectableViewModel.connection,
                                                                        connectionSession: session)
        modal(connectionViewController)
    }
    
    func didSetupConnection(_ connection: Connection, fetchingStarted: Bool) {
        bankConnectableViewModel.fetchingStarted = fetchingStarted
        connectConnection(connection)
    }
    
    func didFinishConnectionProcess() {
        self.refreshData()
    }
    
    func didNotConnect() {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
                                                                           comment: "Не удалось подключиться к банку"),
                                          theme: .error)
        self.refreshData()
    }
    
    func didNotConnect(error: Error) {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
                                                                           comment: "Не удалось подключиться к банку"),
                                          theme: .error)
        self.refreshData()
    }
}

extension BankConnectableProtocol {
    func showAccounts() {
        guard
            let expenseSource = bankConnectableViewModel.expenseSource,
            let connection = bankConnectableViewModel.connection,
            connection.status == .active,
            connection.lastStage == .finish,
            !bankConnectableViewModel.accountConnected
        else {
            return
        }
        slideUp(factory.accountsViewController(delegate: self,                                               
                                               expenseSource: expenseSource))
    }
    
    func didSelect(account: AccountViewModel) {
        connectAccount(account)
    }
}

extension BankConnectableProtocol {
    private func modal(_ viewController: UIViewController?) {
        guard let selfController = self as? UIViewController else { return }
        selfController.modal(viewController)
    }
    
    private func slideUp(_ viewController: UIViewController?) {
        guard let selfController = self as? UIViewController else { return }
        selfController.slideUp(viewController)
    }
}

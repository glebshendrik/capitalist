//
//  BankConnectionController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 07.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyBeaver

protocol BankConnectionControllerProtocol : UIFactoryDependantProtocol,
                                            UIMessagePresenterManagerDependantProtocol,
                                            ProvidersViewControllerDelegate,
                                            ConnectionViewControllerDelegate,
                                            AccountsViewControllerDelegate,
                                            ExperimentalBankFeatureViewControllerDelegate {
    
    var bankConnectionViewModel: BankConnectionViewModel! { get }
    
    func showProviders()
    func setupConnection()
    func showAccounts()
    
    func refreshData()
    func save()
}

extension BankConnectionControllerProtocol {
    func showProviders() {
        modal(factory.providersViewController(delegate: self))
    }
    
    func didSelectProvider(_ providerViewModel: ProviderViewModel) {
        bankConnectionViewModel.providerViewModel = providerViewModel
        showExperimentalFeature()
    }
}

extension BankConnectionControllerProtocol {
    func showExperimentalFeature() {
        modal(factory.experimentalBankFeatureViewController(delegate: self))        
    }
    
    func didChooseUseFeature() {
        bankConnectionViewModel.shouldUseExperimentalFeature = true
        setupConnection()
    }
    
    func didChooseDontUseFeature() {
        bankConnectionViewModel.shouldUseExperimentalFeature = false
        setupConnection()
    }
}

extension BankConnectionControllerProtocol {
    func setupConnection() {        
        messagePresenterManager.showHUD(with: NSLocalizedString("Загрузка подключения к банку...",
                                                                comment: "Загрузка подключения к банку..."))        
        firstly {
            bankConnectionViewModel.loadConnection()
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { _ in
            self.updateConnection()
            self.bankConnectionViewModel.hasActionIntent = false
        }.catch { error in
            self.bankConnectionViewModel.hasActionIntent = false
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
            let connection = bankConnectionViewModel.connection
        else {
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
                                                                               comment: "Не удалось подключиться к банку"),
                                              theme: .error)
            return
        }
        switch connection.status {
            case .active:
                if !bankConnectionViewModel.connectionConnected {
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
                        !bankConnectionViewModel.hasActionIntent
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
                
                
                
//                guard
//                    let interactive = connection.interactive
//                else {
//                    self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
//                                                                                       comment: "Не удалось подключиться к банку"),
//                                                      theme: .error)
//                    return
//                }
//                guard
//                    let nextRefreshPossibleAt = connection.nextRefreshPossibleAt
//                else {
//                    if let stage = connection.lastStage,
//                       !stage.isInteractive {
//                        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
//                                                                                           comment: "Не удалось подключиться к банку"),
//                                                          theme: .error)                        
//                    }
//                    return
//                }
//                if nextRefreshPossibleAt.isInPast && interactive {
//                    if connection.lastStage == .finish {
//                        self.showConnectionSession(type: .refreshing)
//                    }
//                    else {
//                        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку",
//                                                                                           comment: "Не удалось подключиться к банку"),
//                                                          theme: .error)
//                    }
//                }
//                else if !bankConnectionViewModel.connectionConnected {
//                    connectConnection(connection)
//                }
//                else {
//                    showAccounts()
//                }
            case .inactive:
                self.showConnectionSession(type: .reconnecting)
            case .deleted:
                self.showConnectionSession(type: .creating)
        }
    }
    
    func connectConnection(_ connection: Connection) {
        guard
            !bankConnectionViewModel.connectionConnected
        else {
            refreshData()
            return
        }
        bankConnectionViewModel.connectConnection(connection)
        save()
    }
    
    func connectAccount(_ account: AccountViewModel) {
        bankConnectionViewModel.connectAccount(account)
        save()
    }
    
    func disconnectAccount() {
        bankConnectionViewModel.disconnectAccount()
        save()
    }
    
}

extension BankConnectionControllerProtocol {
    func showConnectionSession(type: ConnectionSessionType) {
        messagePresenterManager.showHUD(with: NSLocalizedString("Подготовка подключения к банку...",
                                                                comment: "Подготовка подключения к банку..."))
        
        func connectionSession() -> Promise<ConnectionSession> {
            switch type {
                case .creating:
                    return bankConnectionViewModel.creatingConnectionSession()
                case .refreshing:
                    return bankConnectionViewModel.refreshingConnectionSession()
                case .reconnecting:
                    return bankConnectionViewModel.reconnectingConnectionSession()
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
                                                                        providerViewModel: bankConnectionViewModel.providerViewModel,
                                                                        connection: bankConnectionViewModel.connection,
                                                                        connectionSession: session)
        modal(connectionViewController)
    }
    
    func didSetupConnection(_ connection: Connection) {
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

extension BankConnectionControllerProtocol {
    func showAccounts() {
        guard
            let expenseSource = bankConnectionViewModel.expenseSource,
            let connection = bankConnectionViewModel.connection,
            connection.status == .active,
            connection.lastStage == .finish,
            !bankConnectionViewModel.accountConnected
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

extension BankConnectionControllerProtocol {
    private func modal(_ viewController: UIViewController?) {
        guard let selfController = self as? UIViewController else { return }
        selfController.modal(viewController)
    }
    
    private func slideUp(_ viewController: UIViewController?) {
        guard let selfController = self as? UIViewController else { return }
        selfController.slideUp(viewController)
    }
}

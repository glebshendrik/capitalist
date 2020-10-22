//
//  BankConnectionViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 09.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class BankConnectionViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    var expenseSourceViewModel: ExpenseSourceViewModel? = nil {
        didSet {
            connection = expenseSourceViewModel?.connection
            accountViewModel = expenseSourceViewModel?.accountViewModel
        }
    }
    var expenseSource: ExpenseSource? {
        return expenseSourceViewModel?.expenseSource
    }
    var accountConnection: AccountConnection? {
        return expenseSourceViewModel?.accountConnection
    }
    var providerViewModel: ProviderViewModel? = nil
    var connection: Connection? = nil
    var accountViewModel: AccountViewModel? = nil
    var accountConnectionAttributes: AccountConnectionNestedAttributes? = nil
    
    var shouldUseExperimentalFeature: Bool = false
    var shouldDestroyConnection: Bool = false
    
    var connectionConnected: Bool {
        return accountConnection != nil
    }
    
    var accountConnected: Bool {
        return accountConnection?.account != nil
    }
    
    var fetchDataFrom: Date? {
        return expenseSourceViewModel?.fetchDataFrom
    }
    
    var canConnectBank: Bool {
        return true
        //        return accountCoordinator.hasPlatinumSubscription
    }
    
    var reconnectNeeded: Bool {
        return expenseSourceViewModel?.reconnectNeeded ?? false
    }
    
    var isSyncingWithBank: Bool {
        return expenseSourceViewModel?.isSyncingWithBank ?? false
    }
    
    var syncingWithBankStage: ConnectionStage {
        return expenseSourceViewModel?.syncingWithBankStage ?? .finish
    }
    
    var nextUpdatePossibleAt: String? {
        guard
            let connection = connection,
            let nextRefreshPossibleAt = connection.nextRefreshPossibleAt,
            let interactive = connection.interactive,
            connection.lastStage == .finish,
            interactive,
            nextRefreshPossibleAt.isInFuture
        else {
            return nil
        }
        let nextSyncTitle = NSLocalizedString("Следующая синхронизация с банком:",
                                              comment: "")
        return "\(nextSyncTitle)\n\(nextRefreshPossibleAt.dateTimeString(ofStyle: .short))"
    }
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.accountCoordinator = accountCoordinator
    }
    
    func set(expenseSource: ExpenseSourceViewModel?) {
        self.expenseSourceViewModel = expenseSource
        // ???
//        self.accountViewModel = nil
        if let accountConnection = expenseSourceViewModel?.accountConnection {
            accountConnectionAttributes =
                AccountConnectionNestedAttributes(id: accountConnection.id,
                                                  connectionId: connection?.id,
                                                  accountId: accountConnection.account?.id,
                                                  shouldDestroy: nil)
        }
        
    }
    
    func loadConnection() -> Promise<Connection> {
        if let connection = connection {
            return Promise.value(connection)
        }
        guard
            let provider = providerViewModel?.provider
        else {
            return Promise(error: BankConnectionError.noProviderToLoadConnection)
        }
        return
            firstly {
                bankConnectionsCoordinator.loadConnection(for: provider)
            }.get { connection in
                self.connection = connection
            }
    }
    
    func creatingConnectionSession() -> Promise<ConnectionSession> {
        if let connection = connection,
           let session = connection.session,
           session.expiresAt.isInFuture,
           session.type == .creating {
            
            return Promise.value(session)
        }
        if let provider = providerViewModel?.provider,
           let expenseSource = expenseSource {
            return bankConnectionsCoordinator.createCreatingConnectionSession(provider: provider,
                                                                              expenseSource: expenseSource,
                                                                              useMaxFetchInterval: shouldUseExperimentalFeature)
        }
        if let connection = connection {
            return bankConnectionsCoordinator.createCreatingConnectionSession(providerCode: connection.providerCode,
                                                                              countryCode: connection.countryCode,
                                                                              fromDate: fetchDataFrom)
        }
        return Promise(error: BankConnectionError.canNotCreateConnection)
    }
    
    func reconnectingConnectionSession() -> Promise<ConnectionSession> {
        guard let connection = connection else {
            return Promise(error: BankConnectionError.canNotCreateConnection)
        }
        return bankConnectionsCoordinator.createReconnectingConnectionSession(connection: connection,
                                                                              fromDate: fetchDataFrom)
    }
    
    func refreshingConnectionSession() -> Promise<ConnectionSession> {
        guard let connection = connection else {
            return Promise(error: BankConnectionError.canNotCreateConnection)
        }
        return bankConnectionsCoordinator.createRefreshingConnectionSession(connection: connection,
                                                                            fromDate: fetchDataFrom)
    }
    
    func connectConnection(_ connection: Connection) {
        self.connection = connection
        
        var accountConnectionId: Int? = nil
        if  let accountConnectionAttributes = accountConnectionAttributes,
            accountConnectionAttributes.connectionId == connection.id {
            
            accountConnectionId = accountConnectionAttributes.id
        }
        
        accountConnectionAttributes =
            AccountConnectionNestedAttributes(id: accountConnectionId,
                                              connectionId: connection.id,
                                              accountId: accountViewModel?.id,
                                              shouldDestroy: nil)
    }
    
    func connectAccount(_ accountViewModel: AccountViewModel) {
        self.accountViewModel = accountViewModel
        
        var accountConnectionId: Int? = nil
        if  let accountConnectionAttributes = accountConnectionAttributes,
            accountConnectionAttributes.accountId == accountViewModel.id {
            
            accountConnectionId = accountConnectionAttributes.id
        }
        
        accountConnectionAttributes =
            AccountConnectionNestedAttributes(id: accountConnectionId,
                                              connectionId: connection?.id,
                                              accountId: accountViewModel.id,
                                              shouldDestroy: nil)
    }
    
    func disconnectAccount() {
        connection = nil
        accountViewModel = nil
        accountConnectionAttributes?.id = expenseSourceViewModel?.accountConnection?.id
        accountConnectionAttributes?.shouldDestroy = true
    }
}

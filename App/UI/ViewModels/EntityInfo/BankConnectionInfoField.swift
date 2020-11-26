//
//  BankWarningInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class BankConnectionInfoField : EntityInfoField {
    private let fieldId: String
    private let bankConnectableViewModel: BankConnectableViewModel
    
    var type: EntityInfoFieldType {
        return .bankConnection
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, bankConnectableViewModel: BankConnectableViewModel) {
        self.fieldId = fieldId
        self.bankConnectableViewModel = bankConnectableViewModel
    }
}

// Bank Connectable Properties
extension BankConnectionInfoField {
    var isSyncing: Bool {
        return bankConnectableViewModel.isSyncingWithBank
    }
    
    var stage: ConnectionStage {
        return bankConnectableViewModel.syncingWithBankStage
    }
    
    var interactiveCredentials: [InteractiveCredentialsField] {
        return bankConnectableViewModel.interactiveCredentials
    }
    
    var hasInteractiveCredentials: Bool {
        return bankConnectableViewModel.hasInteractiveCredentials
    }
    
    var hasInteractiveCredentialsValues: Bool {
        return bankConnectableViewModel.hasInteractiveCredentialsValues
    }
}

// Properties
extension BankConnectionInfoField {
    var title: String? {
        return isSyncing
            ? NSLocalizedString("Обновление подключения к банку", comment: "")
            : NSLocalizedString("Нет подключения к банку", comment: "")
    }
    
    var message: String? {
        return isSyncing
            ? stage.message
            : NSLocalizedString("Провайдер подключения к банку не может установить соединение. Для обновления данных требуется подключиться к банку",
                                comment: "")
    }
    
    var reconnectButtonText: String? {
        let syncingButtonText = stage.isInteractive && hasInteractiveCredentials
            ? NSLocalizedString("Отправить", comment: "")
            : NSLocalizedString("Синхронизация...", comment: "")
        return isSyncing
            ? syncingButtonText
            : NSLocalizedString("Подключиться", comment: "")
    }
    
    var connectButtonText: String? {
        let syncingButtonText = stage.isInteractive && hasInteractiveCredentials
            ? NSLocalizedString("Отправить", comment: "")
            : NSLocalizedString("Синхронизация...", comment: "")
        return isSyncing
            ? syncingButtonText
            : NSLocalizedString("Подключиться", comment: "")
    }
    
    var description: String? {
        return bankConnectableViewModel.nextUpdatePossibleAt
    }
}

// Visibility
extension BankConnectionInfoField {
    var isWarningIconHidden: Bool {
        return isSyncing
    }
    
    var isSyncingIndicatorHidden: Bool {
        return !isSyncing
    }
        
    var areCredentialsFieldsHidden: Bool {
        return !(isSyncing && stage.isInteractive && hasInteractiveCredentials)
    }
    
    var isDividerHidden: Bool {
        return !areCredentialsFieldsHidden || isReconnectButtonHidden
    }
    
    var isReconnectButtonHidden: Bool {
        return false
    }
    
    var isDescriptionHidden: Bool {
        return bankConnectableViewModel.nextUpdatePossibleAt == nil
    }
    
    var isConnectButtonHidden: Bool {
        return false
    }
}

// Permissions
extension BankConnectionInfoField {    
    var isReconnectButtonEnabled: Bool {
        return
            !isSyncing ||
            (hasInteractiveCredentialsValues && stage.isInteractive)
    }
    
    var isConnectButtonEnabled: Bool {
        return
            !isSyncing ||
            (hasInteractiveCredentialsValues && stage.isInteractive)
    }
}

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
    
    func update(_ field: InteractiveCredentialsField) {
        bankConnectableViewModel.update(field)
    }
}

// Bank Connectable Properties
extension BankConnectionInfoField {
    var isReconnectNeeded: Bool {
        return bankConnectableViewModel.reconnectNeeded
    }
    
    var isConnectionConnected: Bool {
        return bankConnectableViewModel.connectionConnected
    }
    
    var isSyncing: Bool {
        return bankConnectableViewModel.isSyncingWithBank
    }
    
    var isInteractiveStage: Bool {
        return stage.isInteractive
    }
    
    var stage: ConnectionStage {
        return bankConnectableViewModel.syncingWithBankStage
    }
    
    var interactiveCredentials: [InteractiveCredentialsField] {
        return bankConnectableViewModel.interactiveCredentialsFields
    }
    
    var hasInteractiveCredentials: Bool {
        return bankConnectableViewModel.hasInteractiveCredentialsFields && isInteractiveStage
    }
    
    var hasInteractiveCredentialsValues: Bool {
        return bankConnectableViewModel.hasInteractiveCredentialsValues && isInteractiveStage
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
        return isSyncing
            ? NSLocalizedString("Отправить", comment: "")
            : NSLocalizedString("Подключиться", comment: "")
    }
    
    var connectButtonText: String? {
        return bankConnectableViewModel.connectionConnected
            ? NSLocalizedString("Отключить банк", comment: "Отключить банк")
            : NSLocalizedString("Подключить банк", comment: "Подключить банк")
    }
    
    var description: String? {
        return bankConnectableViewModel.nextUpdatePossibleAt
    }
    
    var connectButtonBackgroundColorAsset: ColorAsset? {
        return
            isConnectionConnected && (isReconnectNeeded || isSyncing)
                ? nil
                : .blue1
    }
}

// Visibility
extension BankConnectionInfoField {
    var isReconnectViewHidden: Bool {
        return !isReconnectNeeded && !isSyncing
    }
    
    var isWarningIconHidden: Bool {
        return isSyncing
    }
    
    var isSyncingIndicatorHidden: Bool {
        return !isSyncing
    }
        
    var areCredentialsFieldsHidden: Bool {
        return !hasInteractiveCredentials
    }
    
    var isDividerHidden: Bool {
        return hasInteractiveCredentials || isSyncing
    }
    
    var isReconnectButtonHidden: Bool {
        return isSyncing && !hasInteractiveCredentials
    }
    
    var isDescriptionHidden: Bool {
        return bankConnectableViewModel.nextUpdatePossibleAt == nil
    }
    
    var isConnectButtonHidden: Bool {
        return !bankConnectableViewModel.connectable
    }
}

// Permissions
extension BankConnectionInfoField {    
    var isReconnectButtonEnabled: Bool {
        return !isSyncing || hasInteractiveCredentialsValues
    }
    
    var isConnectButtonEnabled: Bool {
        return true
    }
}

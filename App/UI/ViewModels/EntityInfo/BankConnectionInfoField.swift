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
    
    var type: EntityInfoFieldType {
        return .bankConnection
    }
    
    var identifier: String {
        return fieldId
    }
    
    let isSyncing: Bool
    let stage: ConnectionStage
    
    var interactiveCredentials: [ConnectionInteractiveCredentials] = []
    var hasInteractiveCredentials: Bool {
        return !interactiveCredentials.isEmpty
    }
    var hasInteractiveCredentialsValues: Bool {
        guard
            hasInteractiveCredentials
        else {
            return false
        }
        return interactiveCredentials.all { credentials in
            guard
                let nature = credentials.nature,
                let value = credentials.value
            else {
                return false
            }
            return nature.isPresentable && !value.isEmpty && !value.isWhitespace
        }
    }

    
    
    var isWarningIconHidden: Bool {
        return isSyncing
    }
    
    var isSyncingIndicatorHidden: Bool {
        return !isSyncing
    }
    
    var areCredentialsFieldsHidden: Bool {
        return !(isSyncing && stage.isInteractive && hasInteractiveCredentials)
    }
    
    var isButtonEnabled: Bool {
        return
            !isSyncing ||
            (hasInteractiveCredentialsValues && stage.isInteractive)
    }
    
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
    
    var buttonText: String? {
        let syncingButtonText = stage.isInteractive && hasInteractiveCredentials
            ? NSLocalizedString("Отправить", comment: "")
            : NSLocalizedString("Синхронизация...", comment: "")
        return isSyncing
            ? syncingButtonText
            : NSLocalizedString("Подключиться", comment: "")
    }
    
    init(fieldId: String, isSyncing: Bool, stage: ConnectionStage, interactiveCredentials: [ConnectionInteractiveCredentials] = []) {
        self.fieldId = fieldId
        self.isSyncing = isSyncing
        self.stage = stage
        self.interactiveCredentials = interactiveCredentials
    }
}

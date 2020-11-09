//
//  BankWarningInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class BankWarningInfoField : EntityInfoField {
    private let fieldId: String
    let title: String?
    let message: String?
    let buttonText: String?
    let isSyncing: Bool
    let stage: ConnectionStage
    
    var interactiveCredentials: [ConnectionInteractiveCredentials] = []
    var hasInteractiveCredentials: Bool {
        guard
            !interactiveCredentials.isEmpty
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

    var type: EntityInfoFieldType {
        return .bankWarning
    }
    
    var identifier: String {
        return fieldId
    }
    
    var isWarningIconHidden: Bool {
        return isSyncing
    }
    
    var isSyncingIndicatorHidden: Bool {
        return !isSyncing
    }
    
    var areCredentialsFieldsHidden: Bool {
        return !(isSyncing && (stage == .interactive || stage == .interactiveCredentialsResendRequired))
    }
    
    var isButtonEnabled: Bool {
        return
            !isSyncing ||
            (hasInteractiveCredentials &&
                (stage == .interactive || stage == .interactiveCredentialsResendRequired))
    }
    
    init(fieldId: String, isSyncing: Bool, stage: ConnectionStage, interactiveCredentials: [ConnectionInteractiveCredentials] = []) {
        self.fieldId = fieldId
        self.isSyncing = isSyncing
        self.stage = stage
        self.interactiveCredentials = interactiveCredentials
        
        title = isSyncing
            ? NSLocalizedString("Обновление подключения к банку", comment: "")
            : NSLocalizedString("Нет подключения к банку", comment: "")
        
        message = isSyncing
            ? stage.message
            : NSLocalizedString("Провайдер подключения к банку не может установить соединение. Для обновления данных требуется подключиться к банку",
                                comment: "")
        
        let syncingButtonText = (stage == .interactive || stage == .interactiveCredentialsResendRequired)
            ? NSLocalizedString("Отправить", comment: "")
            : NSLocalizedString("Синхронизация...", comment: "")
        buttonText = isSyncing
            ? syncingButtonText
            : NSLocalizedString("Подключиться", comment: "")        
    }
}

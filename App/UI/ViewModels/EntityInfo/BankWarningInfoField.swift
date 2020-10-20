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
    
    var isButtonEnabled: Bool {
        return !isSyncing
    }
    
    init(fieldId: String, isSyncing: Bool, stage: ConnectionStage) {
        self.fieldId = fieldId
        self.isSyncing = isSyncing
        self.stage = stage
        
        title = isSyncing
            ? NSLocalizedString("Обновление подключения к банку", comment: "")
            : NSLocalizedString("Нет подключения к банку", comment: "")
        
        message = isSyncing
            ? stage.message
            : NSLocalizedString("Провайдер подключения к банку не может установить соединение. Для обновления данных требуется подключиться к банку",
                                comment: "")
        
        buttonText = isSyncing
            ? NSLocalizedString("Синхронизация...", comment: "")
            : NSLocalizedString("Подключиться", comment: "")        
    }
}

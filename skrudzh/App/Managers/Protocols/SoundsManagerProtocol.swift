//
//  SoundsManagerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

protocol SoundsManagerProtocol {
    var soundsEnabled: Bool { get }
    func playTransactionStartedSound()
    func playTransactionCompletedSound()
    func setSounds(enabled: Bool)
}

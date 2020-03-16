//
//  BiometricVerificationManagerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16.03.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol BiometricVerificationManagerProtocol {
    var inAppBiometricVerificationEnabled: Bool { get }
    var systemBiometricVerificationEnabled: Bool { get }
    func setInAppBiometricVerification(enabled: Bool)
    func authenticateWithBioMetrics() -> Promise<Void>
    func authenticateWithPasscode() -> Promise<Void>
}

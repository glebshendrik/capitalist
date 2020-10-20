//
//  BiometricVerificationManagerProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.03.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol BiometricVerificationManagerProtocol {
    var shouldVerify: Bool { get }
    var inAppBiometricVerificationEnabled: Bool { get }
    var systemBiometricVerificationEnabled: Bool { get }
    var allowableReuseDuration: TimeInterval? { get set }
    func setInAppBiometricVerification(enabled: Bool)
    func authenticateWithBioMetrics() -> Promise<Void>
    func authenticateWithPasscode() -> Promise<Void>
}

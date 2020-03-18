//
//  BiometricVerificationManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17.03.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import BiometricAuthentication
import PromiseKit

class BiometricVerificationManager : BiometricVerificationManagerProtocol {
    enum Keys : String {
        case biometricVerificationEnabled
    }
    
    var shouldVerify: Bool {
        return systemBiometricVerificationEnabled && inAppBiometricVerificationEnabled
    }
    
    var inAppBiometricVerificationEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Keys.biometricVerificationEnabled.rawValue)
    }
    
    var systemBiometricVerificationEnabled: Bool {
        return BioMetricAuthenticator.canAuthenticate()
    }
        
    var allowableReuseDuration: TimeInterval? {
        get {            
            return BioMetricAuthenticator.shared.allowableReuseDuration
        }
        set {
            BioMetricAuthenticator.shared.allowableReuseDuration = newValue
        }
    }
    
    func setInAppBiometricVerification(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.biometricVerificationEnabled.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func authenticateWithBioMetrics() -> Promise<Void> {
        return  firstly {
                    authenticateWithBioMetricsPromise()
                }.recover { _ in
                    self.authenticateWithPasscode()
                }
    }
    
    func authenticateWithPasscode() -> Promise<Void> {
        return Promise { seal in
            BioMetricAuthenticator.authenticateWithPasscode(reason: "") { (result) in
                switch result {
                case .success(_):
                    seal.fulfill(())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private func authenticateWithBioMetricsPromise() -> Promise<Void> {
        return Promise { seal in
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                switch result {
                case .success(_):
                    seal.fulfill(())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}

//
//  PasscodeViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import BiometricAuthentication

class PasscodeViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showBioMetricsAuthentication()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @IBAction func didTapJoinButton(_ sender: Any) {
        showBioMetricsAuthentication()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showBioMetricsAuthentication() {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
            switch result {
            case .success(_):
                self?.close()
            case .failure(let error):
                self?.showPasscodeAuthentication(message: error.message())
            }
        }
    }
        
    func showPasscodeAuthentication(message: String) {
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.close()
            case .failure(let error):
                print(error.message())
            }
        }
    }
}

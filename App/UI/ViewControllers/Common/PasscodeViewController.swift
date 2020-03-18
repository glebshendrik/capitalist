//
//  PasscodeViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class PasscodeViewController : UIViewController {
    var biometricVerificationManager: BiometricVerificationManagerProtocol!
    
    @IBOutlet weak var activateButton: UIButton!
    
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
        activateButton.isHidden = true
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showBioMetricsAuthentication() {
        firstly {
            biometricVerificationManager.authenticateWithBioMetrics()
        }.done {
            self.close()
        }.catch { _ in
            self.activateButton.isHidden = false
        }
    }
}

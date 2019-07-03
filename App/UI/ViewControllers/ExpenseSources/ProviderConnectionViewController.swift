//
//  BankConnectionViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SaltEdge

protocol ProviderConnectionViewControllerDelegate {
    func didConnect(connectionSecret: String)
    func didNotConnect()
    func didNotConnect(with: Error)
}

class ProviderConnectionViewController : UIViewController {
    
    @IBOutlet weak var webView: SEWebView!
    
    var delegate: ProviderConnectionViewControllerDelegate?
    var connectionSecret: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        webView.stateDelegate = self
    }
}

extension ProviderConnectionViewController: SEWebViewDelegate {
    func webView(_ webView: SEWebView, didReceiveCallbackWithResponse response: SEConnectResponse) {
        switch response.stage {
        case .success:
            guard let connectionSecret = connectionSecret else {
                delegate?.didNotConnect()
                return
            }
            self.delegate?.didConnect(connectionSecret: connectionSecret)
        case .fetching:
            self.connectionSecret = response.secret
        case .error:
            delegate?.didNotConnect()
        }
    }
    
    func webView(_ webView: SEWebView, didReceiveCallbackWithError error: Error) {
        delegate?.didNotConnect(with: error)
    }
}

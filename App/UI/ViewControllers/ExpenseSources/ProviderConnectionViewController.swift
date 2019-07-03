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
    func didConnect(connectionId: String, connectionSecret: String, providerViewModel: ProviderViewModel)
    func didNotConnect()
    func didNotConnect(with: Error)
}

class ProviderConnectionViewController : UIViewController {
    
    @IBOutlet weak var webView: SEWebView!
    
    var delegate: ProviderConnectionViewControllerDelegate?
    var providerViewModel: ProviderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        connect()
    }
    
    private func setupUI() {
        webView.stateDelegate = self
    }
    
    private func connect() {
        if let url = providerViewModel.connectURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ProviderConnectionViewController: SEWebViewDelegate {
    func webView(_ webView: SEWebView, didReceiveCallbackWithResponse response: SEConnectResponse) {
        switch response.stage {
        case .success:
            guard let connectionSecret = response.secret,
                  let connectionId = response.connectionId else {
                delegate?.didNotConnect()
                return
            }
            delegate?.didConnect(connectionId: connectionId, connectionSecret: connectionSecret, providerViewModel: providerViewModel)
            close()
        case .fetching:
            print("fetching connection")
        case .error:
            delegate?.didNotConnect()
            close()
        }
    }
    
    func webView(_ webView: SEWebView, didReceiveCallbackWithError error: Error) {
        delegate?.didNotConnect(with: error)
        close()
    }
}

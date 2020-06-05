//
//  BankConnectionViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SaltEdge
import PromiseKit

protocol ProviderConnectionViewControllerDelegate {
    func didConnectTo(_ providerViewModel: ProviderViewModel, connection: Connection)
    func didNotConnect()
    func didNotConnect(with: Error)
}

class ProviderConnectionViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var webView: SEWebView!
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var delegate: ProviderConnectionViewControllerDelegate?
    var viewModel: ProviderConnectionViewModel!
    var providerViewModel: ProviderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        connect()
    }
    
    private func setupUI() {
        webView.stateDelegate = self
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.title = NSLocalizedString("Подключение к банку", comment: "Подключение к банку")
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
            didConnect(connectionId: connectionId, connectionSecret: connectionSecret, providerViewModel: providerViewModel)
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
    
    func webView(_ webView: SEWebView, didHandleRequestUrl url: URL) {
        
    }
}

extension ProviderConnectionViewController {    
    func didConnect(connectionId: String, connectionSecret: String, providerViewModel: ProviderViewModel) {
        guard let delegate = delegate else {
            messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
            close()
            return
        }
        messagePresenterManager.showHUD(with: NSLocalizedString("Создание подключения к банку...", comment: "Создание подключения к банку..."))
        firstly {
            self.viewModel.createConnection(connectionId: connectionId, connectionSecret: connectionSecret, providerViewModel: providerViewModel)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { connection in
            self.close()
            delegate.didConnectTo(providerViewModel, connection: connection)
        }.catch { error in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
        }
    }
}

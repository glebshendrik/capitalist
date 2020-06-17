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
import SwiftyBeaver

protocol ConnectionViewControllerDelegate {
    func didConnectToConnection(_ providerViewModel: ProviderViewModel, connection: Connection)
    func didNotConnect()
    func didNotConnect(error: Error)
}

class ConnectionViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var webView: SEWebView!
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var delegate: ConnectionViewControllerDelegate?
    var viewModel: ProviderConnectionViewModel!
    
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
        if let url = viewModel.connectionURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func close(completion: (() -> Void)? = nil) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }
}

extension ConnectionViewController: SEWebViewDelegate {
    func webView(_ webView: SEWebView, didReceiveCallbackWithResponse response: SEConnectResponse) {
        switch response.stage {
        case .success:
            guard let connectionSecret = response.secret,
                  let connectionId = response.connectionId else {
                SwiftyBeaver.error(response)
                delegate?.didNotConnect()
                close()
                return
            }
            setupConnection(id: connectionId, secret: connectionSecret)
        case .fetching:
            print("fetching connection")
        case .error:
            SwiftyBeaver.error(response)
//            delegate?.didNotConnect()
//            close()
        }
    }
    
    func webView(_ webView: SEWebView, didReceiveCallbackWithError error: Error) {
        SwiftyBeaver.error(error)
//        delegate?.didNotConnect(error: error)
//        close()
    }
    
    func webView(_ webView: SEWebView, didHandleRequestUrl url: URL) {
        
    }
}

extension ConnectionViewController {
    func setupConnection(id: String, secret: String) {
        guard let delegate = delegate, let provider = viewModel.providerViewModel else {
            messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
            close()
            return
        }
        messagePresenterManager.showHUD(with: NSLocalizedString("Создание подключения к банку...", comment: "Создание подключения к банку..."))
        firstly {
            viewModel.setupConnection(id: id, secret: secret)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { connection in
            self.close() {                
                delegate.didConnectToConnection(provider, connection: connection)
            }
        }.catch { error in
            self.close()
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
        }
    }
}

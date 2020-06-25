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

protocol ConnectionViewControllerDelegate : class {
    func didConnectToConnection(_ providerViewModel: ProviderViewModel?, connection: Connection)
    func didNotConnect()
    func didNotConnect(error: Error)
}

class ConnectionViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var webView: SEWebView!
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    weak var delegate: ConnectionViewControllerDelegate?
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
        
    override func closeButtonHandler(completion: (() -> Void)? = nil) {
        guard viewModel.shouldAskClose else {
            close(completion: completion)
            return
        }
        askClose(completion: completion)
    }
        
    func askClose(completion: (() -> Void)? = nil) {
        let closeAction = UIAlertAction(title: NSLocalizedString("Закрыть", comment: ""),
                                              style: .destructive,
                                              handler: { _ in
                                                    self.close(completion: completion)
                                                })
        
        sheet(title: NSLocalizedString("Необходимо дождаться шага ввода кода подтверждения", comment: ""),
              actions: [closeAction],
              message: nil,
              preferredStyle: .alert)
    }
    
    func close(completion: (() -> Void)? = nil) {
        postFinantialDataUpdated()
        super.closeButtonHandler(completion: completion)
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
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
                closeButtonHandler()
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
        guard let delegate = delegate else {
            messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
            closeButtonHandler()
            return
        }
        messagePresenterManager.showHUD(with: NSLocalizedString("Создание подключения к банку...", comment: "Создание подключения к банку..."))
        firstly {
            viewModel.setupConnection(id: id, secret: secret)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { connection in
            self.closeButtonHandler() {
                delegate.didConnectToConnection(self.viewModel.providerViewModel, connection: connection)
            }
        }.catch { error in
            self.closeButtonHandler()
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
        }
    }
}

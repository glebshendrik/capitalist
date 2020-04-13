//
//  UIMessagePresenterManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import SVProgressHUD
import PromiseKit
import SwiftMessages
import SwifterSwift

class UIMessagePresenterManager : UIMessagePresenterManagerProtocol {
    
    func showHUD() {
        SVProgressHUD.show()
    }
    
    func showHUD(with message: String) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message)
    }
    
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
    
    func show(navBarMessage: String, theme: Theme) {
        show(navBarMessage: navBarMessage,
             theme: theme,
             duration: .short)
    }
    
    func show(navBarMessage: String, theme: Theme, duration: Duration) {
        show(message: navBarMessage,
             theme: theme,
             presentationStyle: .top,
             duration: duration.rawValue,
             interactive: true)
    }
    
    func show(validationMessage: String) {
        show(message: validationMessage,
             theme: .error,
             presentationStyle: .bottom,
             duration: Duration.short.rawValue,
             interactive: true)
    }
    
    func show(validationMessages: [String: String]) {        
        for (_, validationMessage) in validationMessages {
            show(validationMessage: validationMessage)
        }
    }
    
    func show(notificationMessage: String, actionOnTap: @escaping () -> ()) {
        show(message: notificationMessage,
             theme: .info,
             presentationStyle: .top,
             duration: Duration.normal.rawValue,
             interactive: true,
             actionOnTap: actionOnTap)
    }
    
    private func show(message: String,
                      theme: Theme,
                      presentationStyle: SwiftMessages.PresentationStyle,
                      duration: TimeInterval,
                      interactive: Bool = false,
                      actionOnTap: (() -> ())? = nil) {
        
        SwiftMessages.pauseBetweenMessages = 0.01
        
        let config = messageConfig(presentationStyle: presentationStyle,
                                   duration: duration,
                                   interactive: interactive)
        
        let view = messageView(message: message,
                               theme: theme,
                               presentationStyle: presentationStyle,
                               actionOnTap: actionOnTap)
        
        SwiftMessages.show(config: config, view: view)
    }
    
    private func messageConfig(presentationStyle: SwiftMessages.PresentationStyle,
                               duration: TimeInterval,
                               interactive: Bool) -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = presentationStyle
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .seconds(seconds: duration)
        config.dimMode = .gray(interactive: interactive)
        config.interactiveHide = interactive
        config.preferredStatusBarStyle = .default
        return config
    }
    
    private func messageView(message: String,
                             theme: Theme,
                             presentationStyle: SwiftMessages.PresentationStyle,
                             actionOnTap: (() -> ())?) -> MessageView {
        
        var layout = MessageView.Layout.cardView
        if case Theme.error = theme {
            layout = .messageView
        }
        
        let view = MessageView.viewFromNib(layout: layout)
        
        view.configureDropShadow()
        view.configureContent(title: "", body: message)
        
        view.iconImageView?.isHidden = true
        
        view.button?.setTitle(nil, for: .normal)
        
        
        if case Theme.error = theme {
            view.configureTheme(backgroundColor: UIColor.by(.black2),
                                foregroundColor: UIColor.by(.white100))
            view.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
        }
        else {
            view.configureTheme(theme)
        }
        
        view.button?.backgroundColor = UIColor.clear
        view.button?.tintColor = view.titleLabel?.textColor
        view.button?.setImage(UIImage(named: "close-icon"), for: .normal)
        
        view.buttonTapHandler = { _ in
            SwiftMessages.hide()
        }
        
        view.tapHandler = { _ in
            SwiftMessages.hide()
            actionOnTap?()
        }
        
        return view
    }
    
    func showAlert(
        title: String,
        message: String,
        actions: [MessageDialogAction],
        from viewController: UIViewController) -> Promise<MessageDialogAction> {
        
        return Promise<MessageDialogAction> { seal in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Add the actions
            for action in actions {
                
                let style: UIAlertAction.Style = {
                    switch action.category {
                    case .normal, .dismissal:
                        return .default
                    case .destructive:
                        return .destructive
                    }
                }()
                
                alertController.addAction(UIAlertAction(title: action.title, style:style, handler: { _ in
                    seal.fulfill(action)
                }))
            }
            
            // Present the controller
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}

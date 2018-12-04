//
//  UIMessagePresenterManager.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import SVProgressHUD
import PromiseKit
import SwiftMessages

class UIMessagePresenterManager : UIMessagePresenterManagerProtocol {
    
    private let notificationPresentingDuration = 3.0
    private let navBarPresentingDuration = 3.0
    private let validationPresentingDuration = 1.5
    
    func showHUD() {
        SVProgressHUD.show()
    }
    
    func showHUD(with message: String) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message)
    }
    
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
    
    func show(navBarMessage: String, theme: Theme) {
        show(message: navBarMessage,
             theme: theme,
             presentationStyle: .top,
             duration: navBarPresentingDuration)
    }
    
    func show(validationMessage: String) {
        show(message: validationMessage,
             theme: .error,
             presentationStyle: .bottom,
             duration: validationPresentingDuration)
    }
    
    func show(notificationMessage: String, actionOnTap: @escaping () -> ()) {
        show(message: notificationMessage,
             theme: .info,
             presentationStyle: .top,
             duration: notificationPresentingDuration,
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
        
        var config = SwiftMessages.Config()

        config.presentationStyle = presentationStyle
        
        // Display in a window at the specified window level: UIWindow.Level.statusBar
        // displays over the status bar while UIWindow.Level.normal displays under.
        config.presentationContext = .window(windowLevel: .normal)
        
        config.duration = .seconds(seconds: duration)
        
        // Dim the background like a popover view. Hide when the background is tapped.
        config.dimMode = interactive ? .none : .gray(interactive: interactive)
        
        // The interactive pan-to-hide gesture.
        config.interactiveHide = interactive
        
        // Specify a status bar style to if the message is displayed directly under the status bar.
        config.preferredStatusBarStyle = .lightContent
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(theme)
        view.configureDropShadow()
        view.configureContent(title: "", body: message)
        view.button?.isHidden = true
        
        view.tapHandler = { _ in
            SwiftMessages.hide()
            actionOnTap?()
        }
        
        SwiftMessages.show(config: config, view: view)
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

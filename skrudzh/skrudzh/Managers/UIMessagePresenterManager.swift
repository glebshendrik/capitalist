//
//  UIMessagePresenterManager.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import SVProgressHUD
import CWStatusBarNotification
import PromiseKit

class UIMessagePresenterManager : UIMessagePresenterManagerProtocol {
    
    private let presentingDuration = 3.0
    
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
    
    func showNavBarMessage(message: String, category: NavBarMessageCategory) {
        showMessage(message: message, category: category)
    }
    
    func showNotificationMessage(message: String, actionOnTap: @escaping () -> ()) {
        showMessage(message: message, category: .normal, actionOnTap: actionOnTap)
    }
    
    fileprivate func showMessage(message: String, category: NavBarMessageCategory, actionOnTap: (() -> ())? = nil) {
        let statusBarNotification = createStatusBarNotification(for: category)
        
        statusBarNotification.notificationTappedBlock = {
            statusBarNotification.dismiss()
            actionOnTap?()
        }
        
        statusBarNotification.display(withMessage: message, forDuration: presentingDuration)
    }
    
    fileprivate func createStatusBarNotification(for messageCategory: NavBarMessageCategory) -> CWStatusBarNotification {
        let notification = CWStatusBarNotification()
        notification.notificationStyle = .navigationBarNotification
        notification.notificationAnimationInStyle = .top
        notification.notificationAnimationOutStyle = .top
        notification.multiline = true
        notification.notificationLabelBackgroundColor = messageCategory == .error
            ? UIColor.init(red: 210 / 255.0, green: 50 / 255.0, blue: 55 / 255.0, alpha: 1.0)
            : .black
        notification.notificationLabelTextColor = .white
        notification.notificationLabelFont = UIFont.systemFont(ofSize: 16.0)
        
        return notification
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

//
//  NotificationsHandler.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit

class NotificationsHandler: NotificationsHandlerProtocol {
    
    private let navigator: NavigatorProtocol
    private let messagePresenterManager: UIMessagePresenterManagerProtocol
    
    init(navigator: NavigatorProtocol, messagePresenterManager: UIMessagePresenterManagerProtocol) {
        self.navigator = navigator
        self.messagePresenterManager = messagePresenterManager
    }
    
    func handleNotification(category: NotificationCategory?,
                            action: NotificationAction?,
                            title: String?,
                            message: String?,
                            applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        let applicationWasActive = state == UIApplication.State.active
        
        if applicationWasActive {
            navigator.updateBadges()
            
            if let viewController = category?.destinationViewController(with: action), navigator.isDestinationViewControllerVisible(viewController) {
                navigator.triggerDestinationUpdate()
            }
            else if message != nil || title != nil {
                messagePresenterManager.showNotificationMessage(message: (message ?? (title ?? ""))) {
                    self.navigateToDestination(of: category, with: action)
                }
            }
        } else {
            navigateToDestination(of: category, with: action)
        }
    }
    
    private func navigateToDestination(of category: NotificationCategory?, with action: NotificationAction?) {
        guard let viewController = category?.destinationViewController(with: action) else { return }
        navigator.navigate(to: viewController)
    }
}

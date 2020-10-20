//
//  NotificationsHandler.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class NotificationsHandler: NotificationsHandlerProtocol {
    
    private let navigator: NavigatorProtocol
    
    init(navigator: NavigatorProtocol) {
        self.navigator = navigator
    }
    
    func handleNotification(category: NotificationCategory?,
                            action: NotificationAction?,
                            applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        navigator.updateBadges()
        
        let applicationWasActive = state == UIApplication.State.active
        
        if  applicationWasActive,
            let category = category,
            let viewController = category.destinationViewController(with: action),
            navigator.isDestinationViewControllerVisible(viewController, with: category) {
            
            navigator.triggerDestinationUpdate()
        }
        else {
            navigateToDestination(of: category, with: action)
        }
    }
    
    private func navigateToDestination(of category: NotificationCategory?, with action: NotificationAction?) {
        guard
            let category = category,
            let viewController = category.destinationViewController(with: action)
        else {
            return
        }
        navigator.navigate(to: viewController, with: category)
    }
}

//
//  Navigator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import Foundation

class Navigator: NavigatorProtocol {
    
    private let window: UIWindow
    
    private var visibleViewController: UIViewController? {
        return topViewController(of: window.rootViewController)
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func isDestinationViewControllerVisible(_ viewController: Infrastructure.ViewController, with category: NotificationCategory) -> Bool {
        guard
            let visibleViewController = (visibleViewController as? Navigatable)
        else {
            return false
        }
        
        return  visibleViewController.viewController.identifier == viewController.identifier &&
                visibleViewController.presentingCategories.any(matching: { $0.notificationIdentifier == category.notificationIdentifier })
    }
    
    func navigate(to viewController: Infrastructure.ViewController, with category: NotificationCategory) {
        if isDestinationViewControllerVisible(viewController, with: category) {
            triggerDestinationUpdate()
        }
        else {
            if let rootViewController = (window.rootViewController as? Navigatable) {
                rootViewController.navigate(to: viewController, with: category)
            }
        }
    }
        
    func triggerDestinationUpdate() {
        guard let visibleViewController = (visibleViewController as? Updatable) else { return }
        visibleViewController.update()
    }
    
    func updateBadges() {
        guard let visibleViewController = (window.rootViewController as? Badgeable) else { return }
        visibleViewController.updateBadge()
    }
        
    private func topViewController(of rootViewController: UIViewController?) -> UIViewController? {
        if let navigationController = (rootViewController as? UINavigationController) {
            return topViewController(of: navigationController.visibleViewController)
        }
        
        if let tabBarController = (rootViewController as? UITabBarController) {
            
            return topViewController(of: tabBarController.selectedViewController)
        }
        
        guard let presentedViewController = rootViewController?.presentedViewController else { return rootViewController }
        
        return topViewController(of: presentedViewController)
    }
}

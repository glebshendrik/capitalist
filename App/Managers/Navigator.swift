//
//  Navigator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class Navigator: NavigatorProtocol {
    
    private let window: UIWindow
    
    private var visibleViewController: UIViewController? {
        return topViewController(of: window.rootViewController)
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func isDestinationViewControllerVisible(_ viewController: Infrastructure.ViewController) -> Bool {
        guard let visibleViewController = (visibleViewController as? Navigatable) else { return false }
        
        return visibleViewController.viewController.identifier == viewController.identifier
    }
    
    func triggerDestinationUpdate() {
        guard let visibleViewController = (visibleViewController as? Updatable) else { return }
        visibleViewController.update()
    }
    
    func updateBadges() {
        guard let visibleViewController = (window.rootViewController as? Badgeable) else { return }
        visibleViewController.updateBadge()
    }
    
    func navigate(to viewController: Infrastructure.ViewController) {
        if isDestinationViewControllerVisible(viewController) {
            triggerDestinationUpdate()
        }
        else {
            if let rootViewController = (window.rootViewController as? Navigatable) {
                rootViewController.navigate(to: viewController)
            }
        }
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

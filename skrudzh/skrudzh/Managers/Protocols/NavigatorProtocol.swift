//
//  NavigatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

protocol Navigatable {
    var viewController: ViewControllers { get }
    func navigate(to viewController: ViewControllers)
}

protocol Updatable {
    func update()
}

protocol Badgeable {
    func updateBadge()
}

protocol Scrollable {
    func scrollToTop()
}

protocol NavigatorProtocol {
    func isDestinationViewControllerVisible(_ viewController: ViewControllers) -> Bool
    func navigate(to viewController: ViewControllers)
    func triggerDestinationUpdate()
    func updateBadges()
}

protocol NavigatorDependantProtocol: class {
    var navigator: NavigatorProtocol! { get set }
}


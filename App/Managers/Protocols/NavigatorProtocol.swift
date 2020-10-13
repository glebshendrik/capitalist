//
//  NavigatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

protocol Navigatable {
    var viewController: Infrastructure.ViewController { get }
    var presentingCategories: [NotificationCategory] { get }
    func navigate(to viewController: Infrastructure.ViewController,
                  with category: NotificationCategory)
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
    func isDestinationViewControllerVisible(_ viewController: Infrastructure.ViewController,
                                            with category: NotificationCategory) -> Bool
    func navigate(to viewController: Infrastructure.ViewController,
                  with category: NotificationCategory)
    func triggerDestinationUpdate()
    func updateBadges()
}

protocol NavigatorDependantProtocol: class {
    var navigator: NavigatorProtocol! { get set }
}


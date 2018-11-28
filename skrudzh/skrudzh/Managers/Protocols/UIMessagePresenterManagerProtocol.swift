//
//  UIMessagePresenterManagerProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

enum MessageDialogActionCategory {
    case normal, destructive, dismissal
}

struct MessageDialogAction {
    let title: String
    let category: MessageDialogActionCategory
}

enum NavBarMessageCategory {
    case error, normal
}

protocol UIMessagePresenterManagerDependantProtocol {
    var messagePresenterManager: UIMessagePresenterManagerProtocol! { get set }
}

protocol UIMessagePresenterManagerProtocol {
    func showHUD()
    func showHUD(with message: String)
    func dismissHUD()
    func showNavBarMessage(message: String, category: NavBarMessageCategory)
    func showNotificationMessage(message: String, actionOnTap: @escaping () -> ())
    func showAlert(
        title: String,
        message: String,
        actions: [MessageDialogAction],
        from viewController: UIViewController) -> Promise<MessageDialogAction>
}

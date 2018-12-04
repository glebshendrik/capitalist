//
//  UIMessagePresenterManagerProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftMessages

enum MessageDialogActionCategory {
    case normal, destructive, dismissal
}

struct MessageDialogAction {
    let title: String
    let category: MessageDialogActionCategory
}

protocol UIMessagePresenterManagerDependantProtocol {
    var messagePresenterManager: UIMessagePresenterManagerProtocol! { get set }
}

protocol UIMessagePresenterManagerProtocol {
    func showHUD()
    func showHUD(with message: String)
    func dismissHUD()
    func show(navBarMessage: String, theme: Theme)
    func show(validationMessage: String)
    func show(notificationMessage: String, actionOnTap: @escaping () -> ())
    func showAlert(
        title: String,
        message: String,
        actions: [MessageDialogAction],
        from viewController: UIViewController) -> Promise<MessageDialogAction>
}

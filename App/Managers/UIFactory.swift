//
//  UIFactory.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class UIFactory : UIFactoryProtocol {
    private let router: ApplicationRouterProtocol
    
    init(router: ApplicationRouterProtocol) {
        self.router = router
    }
    
    func iconsViewController(delegate: IconsViewControllerDelegate, iconCategory: IconCategory) -> IconsViewController? {
        let iconsViewController = router.viewController(.IconsViewController) as? IconsViewController
        iconsViewController?.set(iconCategory: iconCategory)
        iconsViewController?.set(delegate: delegate)
        return iconsViewController
    }
    
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> CurrenciesViewController? {
        let currenciesViewController = router.viewController(.CurrenciesViewController) as? CurrenciesViewController
        currenciesViewController?.set(delegate: delegate)
        return currenciesViewController
    }
    
    func reminderEditViewController(delegate: ReminderEditViewControllerDelegate, viewModel: ReminderViewModel) -> ReminderEditViewController? {
        let reminderEditNavigationController = router.viewController(.ReminderEditNavigationController) as? UINavigationController
        let reminderEditViewController = reminderEditNavigationController?.topViewController as? ReminderEditViewController
        reminderEditViewController?.set(reminderViewModel: viewModel, delegate: delegate)
        return reminderEditViewController
    }
}

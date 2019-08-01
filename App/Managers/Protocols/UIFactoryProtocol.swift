//
//  UIFactoryProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol UIFactoryDependantProtocol {
    var factory: UIFactoryProtocol! { get set }
}

protocol UIFactoryProtocol {
    func iconsViewController(delegate: IconsViewControllerDelegate, iconCategory: IconCategory) -> IconsViewController?
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> CurrenciesViewController?
    func reminderEditViewController(delegate: ReminderEditViewControllerDelegate, viewModel: ReminderViewModel) -> ReminderEditViewController?
    func providersViewController(delegate: ProvidersViewControllerDelegate) -> ProvidersViewController?
    func accountsViewController(delegate: AccountsViewControllerDelegate, providerConnection: ProviderConnection, currencyCode: String?) -> AccountsViewController?
    func providerConnectionViewController(delegate: ProviderConnectionViewControllerDelegate, providerViewModel: ProviderViewModel) -> ProviderConnectionViewController?
}

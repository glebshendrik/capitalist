//
//  ProfileViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import ApphudSDK
import StoreKit

class ProfileViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var currentUser: User? = nil
    
    var user: User? {
        return currentUser
    }
    
    var isCurrentUserLoaded: Bool {
        return currentUser != nil
    }
    
    var shouldNotifyAboutRegistrationConfirmation: Bool {
        guard let user = currentUser, !user.guest else {
            return false
        }
        return !user.registrationConfirmed
    }
    
    var currentUserFirstname: String? {
        return currentUser?.firstname
    }
    
    var currentUserEmail: String? {
        return currentUser?.email
    }
    
    var hasActiveSubscription: Bool {
        return accountCoordinator.hasActiveSubscription
    }
    
    var subscriptionTitle: String? {
        guard
            let product = accountCoordinator.activeSubscriptionProduct
        else {
            return NSLocalizedString("Устаревшая версия подписки", comment: "Устаревшая версия подписки")
        }
        return accountCoordinator.subscription == nil
            ? "\(product.localizedTitle): \(product.localizedPrice)"
            : "\(product.localizedTitle): \(product.localizedPricePerPeriod)"
    }
    
    var subscriptionStatus: String? {
        guard
            let subscription = accountCoordinator.subscription
        else {
            return accountCoordinator.hasPremiumUnlimitedSubscription
                ? NSLocalizedString("Активна навсегда", comment: "")
                : nil
        }
        if let cancelledAt = subscription.canceledAt {
            return String.localizedStringWithFormat(NSLocalizedString("Отменена с %@", comment: "Отменена с %@"), cancelledAt.dateString(ofStyle: .medium))
        }
        if subscription.isInRetryBilling {
            return NSLocalizedString("Проблемы с оплатой", comment: "Проблемы с оплатой")
        }
        return String.localizedStringWithFormat(NSLocalizedString("Активна до %@", comment: "Активна до %@"), subscription.expiresDate.dateString(ofStyle: .medium))
    }
        
    var confirmButtonHidden: Bool {
        return currentUser?.registrationConfirmed ?? true
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return accountCoordinator.loadCurrentUser().get { user in
            self.currentUser = user
        }.asVoid()
    }
    
    func logOut() -> Promise<Void> {
        return accountCoordinator.logout()
    }
    
    func destroyUserData() -> Promise<Void> {
        return accountCoordinator.destroyCurrentUserData()
    }
    
    func sendConfirmation() -> Promise<Void> {
        return accountCoordinator.sendConfirmationEmailToCurrentUser()
    }
}

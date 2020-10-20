//
//  MenuViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class MenuViewModel {
    
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var currentUser: User? = nil
    private var budgetViewModel: BudgetViewModel? = nil
        
    var isCurrentUserLoaded: Bool {
        return currentUser != nil
    }
    
    var isCurrentUserGuest: Bool {
        guard let user = currentUser else {
            return true
        }
        return user.guest
    }    
    
    var subscriptionItemHidden: Bool {
        return platinumFeaturesAvailable
    }
    
    var premiumFeaturesAvailable: Bool {
        return accountCoordinator.premiumFeaturesAvailable
    }
    
    var platinumFeaturesAvailable: Bool {
        return accountCoordinator.platinumFeaturesAvailable
    }
    
    var requiredPlans: [SubscriptionPlan] {
        var plans: [SubscriptionPlan] = []
        if !premiumFeaturesAvailable {
            plans.append(.premium)
        }
        if !platinumFeaturesAvailable {
            plans.append(.platinum)
        }
        return plans
    }
            
    var shouldNotifyAboutRegistrationConfirmation: Bool {
        guard let user = currentUser, !user.guest else {
            return false
        }
        return !user.registrationConfirmed
    }
    
    var profileItemHidden: Bool {
        return !isCurrentUserLoaded || isCurrentUserGuest
    }
    
    var joinItemHidden: Bool {
        return !isCurrentUserLoaded || !isCurrentUserGuest
    }
    
    var profileTitle: String? {
        var firstname = currentUser?.firstname
        if firstname != nil && firstname!.trimmed.isEmpty {
            firstname = nil
        }
        return firstname ?? currentUser?.email
    }
    
    var subscriptionItemTitle: String? {
        if !premiumFeaturesAvailable {
            return NSLocalizedString("Premium", comment: "")
        }
        if !platinumFeaturesAvailable {
            return NSLocalizedString("Platinum", comment: "")
        }
        return nil
    }
    
    var incomesAmount: String {
        return budgetViewModel?.incomesAmountRounded ?? ""
    }
    
    var incomesAmountPlanned: String {
        return budgetViewModel?.incomesAmountPlannedRounded ?? ""
    }
    
    var expensesAmount: String {
        return budgetViewModel?.expensesAmountRounded ?? ""
    }
    
    var expensesAmountPlanned: String {
        return budgetViewModel?.expensesAmountPlannedRounded ?? ""
    }
      
    var incomesProgress: CGFloat {
        return budgetViewModel?.incomesProgress ?? 0.0
    }
    
    var expensesProgress: CGFloat {
        return budgetViewModel?.expensesProgress ?? 0.0
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: accountCoordinator.loadCurrentUser(),
                                    accountCoordinator.loadCurrentUserBudget())
                }.get { user, budget in
                    self.currentUser = user
                    self.budgetViewModel = BudgetViewModel(budget: budget)
                }.asVoid()
    }
}

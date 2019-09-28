//
//  CreditsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CreditsViewModel {
    private let creditsCoordinator: CreditsCoordinatorProtocol
    
    private var creditViewModels: [CreditViewModel] = []
    
    var numberOfCredits: Int {
        return creditViewModels.count
    }
    
    init(creditsCoordinator: CreditsCoordinatorProtocol) {
        self.creditsCoordinator = creditsCoordinator
    }
    
    func loadCredits() -> Promise<Void> {
        return  firstly {
                    creditsCoordinator.indexCredits()
                }.get { credits in
                    self.creditViewModels = credits.map { CreditViewModel(credit: $0)}
                }.asVoid()
    }
        
    func creditViewModel(at indexPath: IndexPath) -> CreditViewModel? {
        return creditViewModels.item(at: indexPath.row)
    }
}

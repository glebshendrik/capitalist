//
//  BorrowsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class BorrowsViewModel {
    private let borrowsCoordinator: BorrowsCoordinatorProtocol
    
    private var debtViewModels: [BorrowViewModel] = []
    private var loanViewModels: [BorrowViewModel] = []
    
    var numberOfDebts: Int {
        return debtViewModels.count
    }
    
    var numberOfLoans: Int {
        return loanViewModels.count
    }
    
    var selectedBorrowType: BorrowType = .loan
    
    init(borrowsCoordinator: BorrowsCoordinatorProtocol) {
        self.borrowsCoordinator = borrowsCoordinator
    }
    
    func loadDebts() -> Promise<Void> {
        return  firstly {
                    borrowsCoordinator.indexDebts()
                }.get { debts in
                    self.debtViewModels = debts.map { BorrowViewModel(borrow: $0)}
                }.asVoid()
    }
    
    func loadLoans() -> Promise<Void> {
        return  firstly {
                    borrowsCoordinator.indexLoans()
                }.get { loans in
                    self.loanViewModels = loans.map { BorrowViewModel(borrow: $0)}
                }.asVoid()
    }
    
    func debtViewModel(at indexPath: IndexPath) -> BorrowViewModel? {
        return debtViewModels.item(at: indexPath.row)
    }
    
    func loanViewModel(at indexPath: IndexPath) -> BorrowViewModel? {
        return loanViewModels.item(at: indexPath.row)
    }
}


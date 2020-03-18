//
//  BorrowInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum BorrowInfoField : String {
    case icon
    case whom
    case amount
    case amountReturned
    case amountLeft
    case borrowedAt
    case payday
    case comment
    case transaction
    
    var identifier: String {
        return rawValue
    }
}

enum BorrowInfoError : Error {
    case borrowIsNotSpecified
}

class BorrowInfoViewModel : EntityInfoViewModel {
    private let borrowsCoordinator: BorrowsCoordinatorProtocol
    private let transactionsCoordinator: TransactionsCoordinatorProtocol
    
    var borrowId: Int?
    var borrowType: BorrowType?
    var borrowViewModel: BorrowViewModel?
    var selectedIconURL: URL? = nil
    
    var borrow: Borrow? {
        return borrowViewModel?.borrow
    }
        
    override var title: String? {
        return borrowViewModel?.title
    }
        
    var nameTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt
            ? NSLocalizedString("Кто вам должен", comment: "Кто вам должен")
            : NSLocalizedString("Кому вы должны", comment: "Кому вы должны")
    }
    
    var amountTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt
            ? NSLocalizedString("Сумма долга", comment: "Сумма долга")
            : NSLocalizedString("Сумма займа", comment: "Сумма займа")
    }
    
    var amountReturnedTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt
            ? NSLocalizedString("Вам вернули", comment: "Вам вернули")
            : NSLocalizedString("Вы вернули", comment: "Вы вернули")
    }
        
    var borrowedAtTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt
            ? NSLocalizedString("Когда дали в долг", comment: "Когда дали в долг")
            : NSLocalizedString("Когда взяли взаймы", comment: "Когда взяли взаймы")
    }
        
    var returnTitle: String? {
        guard let type = borrowType, let borrowViewModel = borrowViewModel else { return nil }
        if borrowViewModel.isReturned {
            return type == .debt
                ? NSLocalizedString("Долг возвращен", comment: "Долг возвращен")
                : NSLocalizedString("Займ возвращен", comment: "Займ возвращен")
        }
        else {
            return type == .debt
                ? NSLocalizedString("Возврат долга", comment: "Возврат долга")
                : NSLocalizedString("Вернуть займ", comment: "Вернуть займ")
        }
    }
    
    var returnIconName: String? {
        guard let borrowViewModel = borrowViewModel else { return nil }
        return borrowViewModel.isReturned ? nil : nil
    }
    
    var returnColor: ColorAsset {
        guard let borrowViewModel = borrowViewModel else { return .blue1 }
        return borrowViewModel.isReturned ? .gray1 : .blue1
    }
    
    override init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.borrowsCoordinator = borrowsCoordinator
        self.transactionsCoordinator = transactionsCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, creditsCoordinator: creditsCoordinator, borrowsCoordinator: borrowsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(borrow: BorrowViewModel?) {
        self.borrowId = borrow?.id
        self.borrowType = borrow?.type
        self.borrowViewModel = borrow
        self.selectedIconURL = borrow?.iconURL
    }
    
    override func loadTransactionsBatch(lastGotAt: Date?) -> Promise<[Transaction]> {
        return transactionsCoordinator.index(transactionableId: nil,
                                             transactionableType: nil,
                                             creditId: nil,
                                             borrowId: borrowId,
                                             borrowType: borrowType,
                                             count: transactionsBatchSize,
                                             lastGotAt: lastGotAt)
    }
        
    override func loadEntity() -> Promise<Void> {
        guard let entityId = borrowId else { return Promise(error: BorrowInfoError.borrowIsNotSpecified)}
        return  firstly {
                    loadBorrow(id: entityId)
                }.get { borrow in
                    self.set(borrow: BorrowViewModel(borrow: borrow))
                }.asVoid()
    }
    
    func loadBorrow(id: Int) -> Promise<Borrow> {
        guard let borrowType = borrowType else { return Promise(error: BorrowInfoError.borrowIsNotSpecified)}
        switch borrowType {
        case .debt:
            return borrowsCoordinator.showDebt(by: id)
        case .loan:
            return borrowsCoordinator.showLoan(by: id)
        }
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        guard let borrowViewModel = borrowViewModel else { return [] }
        var fields: [EntityInfoField] = [IconInfoField(fieldId: BorrowInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,
                                                       placeholder: "borrow-default-icon"),
                                         BasicInfoField(fieldId: BorrowInfoField.whom.rawValue,
                                                        title: nameTitle,
                                                        value: borrowViewModel.name)]
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.amount.rawValue,
                                     title: amountTitle,
                                     value: borrowViewModel.amount))
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.amountReturned.rawValue,
                                     title: amountReturnedTitle,
                                     value: borrowViewModel.amountReturned))
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.amountLeft.rawValue,
                                     title: NSLocalizedString("Осталось вернуть", comment: "Осталось вернуть"),
                                     value: borrowViewModel.amountLeft))
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.borrowedAt.rawValue,
                                     title: borrowedAtTitle,
                                     value: borrowViewModel.borrowedAtFormatted))
        
        if let payday = borrowViewModel.paydayFormatted {
            fields.append(BasicInfoField(fieldId: BorrowInfoField.payday.rawValue,
                                         title: NSLocalizedString("Дата возврата", comment: "Дата возврата"),
                                         value: payday))
        }
        
        if let comment = borrowViewModel.comment {
            fields.append(BasicInfoField(fieldId: BorrowInfoField.comment.rawValue,
                                         title: NSLocalizedString("Комментарий", comment: "Комментарий"),
                                         value: comment))
        }
        
        fields.append(ButtonInfoField(fieldId: BorrowInfoField.transaction.rawValue,
                                      title: returnTitle,
                                      iconName: returnIconName,
                                      isEnabled: !borrowViewModel.isReturned,
                                      backgroundColor: returnColor))
        
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        guard let borrowType = borrowType else { return Promise(error: BorrowInfoError.borrowIsNotSpecified)}
        switch borrowType {
        case .debt:
            return borrowsCoordinator.updateDebt(with: updateForm())
        case .loan:
            return borrowsCoordinator.updateLoan(with: updateForm())
        }
    }
         
    private func updateForm() -> BorrowUpdatingForm {
        return BorrowUpdatingForm(id: borrowId,
                                  name: borrowViewModel?.name,
                                  iconURL: selectedIconURL,
                                  amountCents: borrowViewModel?.borrow.amountCents,
                                  borrowedAt: borrowViewModel?.borrow.borrowedAt,
                                  payday: borrowViewModel?.borrow.payday,
                                  comment: borrowViewModel?.borrow.comment,
                                  borrowingTransactionAttributes: nil)
    }
}

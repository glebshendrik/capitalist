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
        return type == .debt ? "Кто вам должен" : "Кому вы должны"
    }
    
    var amountTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt ? "Сумма долга" : "Сумма займа"
    }
    
    var amountReturnedTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt ? "Вам вернули" : "Вы вернули"
    }
        
    var borrowedAtTitle: String? {
        guard let type = borrowType else { return nil }
        return type == .debt ? "Когда дали в долг" : "Когда взяли взаймы"
    }
        
    var returnTitle: String? {
        guard let type = borrowType, let borrowViewModel = borrowViewModel else { return nil }
        if borrowViewModel.isReturned {
            return type == .debt ? "Долг возвращен" : "Займ возвращен"
        }
        else {
            return type == .debt ? "Возврат долга" : "Вернуть займ"
        }
    }
    
    var returnIconName: String? {
        guard let borrowViewModel = borrowViewModel else { return nil }
        return borrowViewModel.isReturned ? nil : nil
    }
    
    var returnColor: ColorAsset {
        guard let borrowViewModel = borrowViewModel else { return .blue5B86F7 }
        return borrowViewModel.isReturned ? .dark404B6F : .blue5B86F7
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol) {
        self.borrowsCoordinator = borrowsCoordinator
        self.transactionsCoordinator = transactionsCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, accountCoordinator: accountCoordinator)
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
                                     value: borrowViewModel.amountRounded))
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.amountReturned.rawValue,
                                     title: amountReturnedTitle,
                                     value: borrowViewModel.amountReturnedRounded))
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.amountLeft.rawValue,
                                     title: "Осталось вернуть",
                                     value: borrowViewModel.amountLeftRounded))
        
        fields.append(BasicInfoField(fieldId: BorrowInfoField.borrowedAt.rawValue,
                                     title: borrowedAtTitle,
                                     value: borrowViewModel.borrowedAtFormatted))
        
        if let payday = borrowViewModel.paydayFormatted {
            fields.append(BasicInfoField(fieldId: BorrowInfoField.payday.rawValue,
                                         title: "Дата возврата",
                                         value: payday))
        }
        
        if let comment = borrowViewModel.comment {
            fields.append(BasicInfoField(fieldId: BorrowInfoField.comment.rawValue,
                                         title: "Комментарий",
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

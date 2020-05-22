//
//  EntityInfoNavigationController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class EntityInfoNavigationController : UINavigationController, UIFactoryDependantProtocol, UIMessagePresenterManagerDependantProtocol, CombinedInfoTableViewCellDelegate, IconInfoTableViewCellDelegate, SwitchInfoTableViewCellDelegate, ButtonInfoTableViewCellDelegate, ReminderInfoTableViewCellDelegate, TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate {
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    
    var entityInfoViewModel: EntityInfoViewModel! {
        return nil
    }
    
    var entityInfoViewController: EntityInfoViewController? {
        return viewControllers.first as? EntityInfoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entityInfoViewController?.viewModel = entityInfoViewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBarUI()
    }
    
    func updateNavBarUI() {
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    func save() {
        entityInfoViewController?.saveData()
    }
    
    func refreshData() {
        entityInfoViewController?.postFinantialDataUpdated()
    }
        
    func showEditScreen() {
        
    }
    
    func didTapIcon(field: IconInfoField?) {
        
    }
        
    func didSwitch(field: SwitchInfoField?) {
        
    }
    
    func didTapInfoButton(field: ButtonInfoField?) {
        
    }
    
    func didTapInfoField(field: BasicInfoField?) {
        
    }
    
    func didTapReminderButton(field: ReminderInfoField?) {
        
    }
    
    var isSelectingTransactionables: Bool {
        return false
    }
    
    func didCreateCredit() {

    }

    func didCreateDebt() {

    }

    func didCreateLoan() {

    }

    func didUpdateCredit() {
        
    }

    func didRemoveCredit() {
        
    }

    func didUpdateDebt() {
        
    }

    func didUpdateLoan() {
        
    }

    func didRemoveDebt() {
        
    }

    func didRemoveLoan() {
        
    }

    func didCreateTransaction(id: Int, type: TransactionType) {
        
    }

    func didUpdateTransaction(id: Int, type: TransactionType) {
        
    }

    func didRemoveTransaction(id: Int, type: TransactionType) {
        
    }
    
    func shouldShowCreditEditScreen(destination: TransactionDestination) {
        showCreditEditScreen(destination: destination)
    }

    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination) {
        showBorrowEditScreen(type: type, source: source, destination: destination)
    }
    
    func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination) {
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination))
    }
    
    func showCreditEditScreen(destination: TransactionDestination) {
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: nil,
                                               destination: destination))
    }
}

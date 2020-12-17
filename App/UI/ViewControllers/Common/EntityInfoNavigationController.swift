//
//  EntityInfoNavigationController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 20.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class EntityInfoNavigationController : UINavigationController, UIFactoryDependantProtocol, UIMessagePresenterManagerDependantProtocol, CombinedInfoTableViewCellDelegate, IconInfoTableViewCellDelegate, SwitchInfoTableViewCellDelegate, ButtonInfoTableViewCellDelegate, ReminderInfoTableViewCellDelegate, BankConnectionInfoTableViewCellDelegate, TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate, Updatable, Navigatable {

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
    
    func didUpdateData() {
        
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
    
    func didTapConnectBankButton(field: BankConnectionInfoField) {
        
    }
    
    func didTapDisconnectBankButton(field: BankConnectionInfoField) {
        
    }
    
    func didTapReconnectBankButton(field: BankConnectionInfoField) {
        
    }
    
    func didTapSendInteractiveFieldsButton(field: BankConnectionInfoField) {
        
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
    
    func shouldShowCreditEditScreen(source: IncomeSourceViewModel?,
                                    destination: TransactionDestination,
                                    creditingTransaction: Transaction?) {
        showCreditEditScreen(source: source, destination: destination, creditingTransaction: creditingTransaction)
    }

    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        showBorrowEditScreen(type: type, source: source, destination: destination, borrowingTransaction: borrowingTransaction)
    }
    
    func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination,
                                               borrowingTransaction: borrowingTransaction))
    }
    
    func showCreditEditScreen(source: IncomeSourceViewModel?,
                              destination: TransactionDestination,
                              creditingTransaction: Transaction?) {
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: nil,
                                               source: source,
                                               destination: destination,
                                               creditingTransaction: creditingTransaction))
    }
    
    var viewController: Infrastructure.ViewController {
        return .EntityInfoViewController
    }
    
    var presentingCategories: [NotificationCategory] {
        return []
    }
    
    func navigate(to viewController: Infrastructure.ViewController, with category: NotificationCategory) {
        
    }
    
    func update() {
        refreshData()
    }
}

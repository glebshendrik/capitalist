//
//  BorrowsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class BorrowsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, ApplicationRouterDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.dark333D5B)
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: BorrowsViewModel!
    
    var debtsSupport: DebtsTableSupport?
    var loansSupport: LoansTableSupport?
    
    @IBOutlet weak var loansLabel: UILabel!
    @IBOutlet weak var debtsLabel: UILabel!
    
    @IBOutlet weak var loansSelectionIndicator: UIView!
    @IBOutlet weak var debtsSelectionIndicator: UIView!
    
    @IBOutlet weak var loansActivityIndicator: UIView!
    @IBOutlet weak var debtsActivityIndicator: UIView!
    
    @IBOutlet weak var loansLoader: UIImageView!
    @IBOutlet weak var debtsLoader: UIImageView!
    
    @IBOutlet weak var loansContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var debtsContainerLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loansTableView: UITableView!
    @IBOutlet weak var debtsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.by(.dark333D5B)
    }
    
    @IBAction func didTapLoans(_ sender: Any) {
        select(.loan)
    }
    
    @IBAction func didTapDebts(_ sender: Any) {
        select(.debt)
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        showNewBorrow()
    }
}

extension BorrowsViewController {
        
    func select(_ borrowType: BorrowType) {
        viewModel.selectedBorrowType = borrowType
        updateTabsUI()
        updateTabContentUI()
    }
    
    func setupUI() {
        setupTables()
        setupLoaders()        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTables() {
        debtsSupport = DebtsTableSupport(viewModel: viewModel, delegate: self)
        loansSupport = LoansTableSupport(viewModel: viewModel, delegate: self)
        
        debtsTableView.dataSource = debtsSupport
        loansTableView.dataSource = loansSupport
        
        debtsTableView.delegate = debtsSupport
        loansTableView.delegate = loansSupport
        
        debtsTableView.tableFooterView = UIView()
        loansTableView.tableFooterView = UIView()
    }
    
    private func setupLoaders() {
        loansLoader.showLoader()
        debtsLoader.showLoader()
    }
    
    func updateUI() {
        updateTabsUI()
        updateTabContentUI()
        updateLoansUI()
        updateDebtsUI()
    }
    
    func updateLoansUI() {
        loansTableView.reloadData(with: .automatic)
    }
    
    func updateDebtsUI() {
        debtsTableView.reloadData(with: .automatic)
    }
    
    func updateTabsUI() {
        
        func tabsAppearances(for borrowType: BorrowType) -> (loans: TabAppearance, debts: TabAppearance) {
            
            let selectedColor = UIColor.by(.textFFFFFF)
            let unselectedColor = UIColor.by(.text9EAACC)
            
            let selectedTabAppearance: TabAppearance = (textColor: selectedColor, isHidden: false)
            let unselectedTabAppearance: TabAppearance = (textColor: unselectedColor, isHidden: true)
            
            switch borrowType {
            case .loan:
                return (loans: selectedTabAppearance,
                        debts: unselectedTabAppearance)
            case .debt:
                return (loans: unselectedTabAppearance,
                        debts: selectedTabAppearance)
            }
        }
        
        let tabsAppearance = tabsAppearances(for: viewModel.selectedBorrowType)
        
        loansLabel.textColor = tabsAppearance.loans.textColor
        debtsLabel.textColor = tabsAppearance.debts.textColor
        
        loansSelectionIndicator.isHidden = tabsAppearance.loans.isHidden
        debtsSelectionIndicator.isHidden = tabsAppearance.debts.isHidden
    }
    
    func updateTabContentUI() {
        
        func layoutPriorities(by borrowType: BorrowType) -> (loansPriority: UILayoutPriority, debtsPriority: UILayoutPriority) {
            
            let low = UILayoutPriority(integerLiteral: 998)
            let high = UILayoutPriority(integerLiteral: 999)
            
            switch borrowType {
            case .loan:
                return (loansPriority: high, debtsPriority: low)
            case .debt:
                return (loansPriority: low, debtsPriority: high)
            }
        }
        
        let priorities = layoutPriorities(by: viewModel.selectedBorrowType)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.loansContainerLeftConstraint.priority = priorities.loansPriority
            self.debtsContainerLeftConstraint.priority = priorities.debtsPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension BorrowsViewController : LoansTableSupportDelegate, DebtsTableSupportDelegate {
    
    func didSelect(debt: BorrowViewModel) {
        showBorrow(debt)
    }
    
    func didSelect(loan: BorrowViewModel) {
        showBorrow(loan)
    }
}

extension BorrowsViewController : BorrowEditViewControllerDelegate {
    func didCreateDebt() {
        loadDebts(finantialDataInvalidated: true)
    }
    
    func didCreateLoan() {
        loadLoans(finantialDataInvalidated: true)
    }
    
    func didUpdateDebt() {
        loadDebts(finantialDataInvalidated: true)
    }
    
    func didUpdateLoan() {
        loadLoans(finantialDataInvalidated: true)
    }
    
    func didRemoveDebt() {
        loadDebts(finantialDataInvalidated: true)
    }
    
    func didRemoveLoan() {
        loadLoans(finantialDataInvalidated: true)
    }
    
    
    func showBorrow(_ borrow: BorrowViewModel) {
        modal(factory.borrowEditViewController(delegate: self, type: borrow.type, borrowId: borrow.id, expenseSourceFrom: nil, expenseSourceTo: nil))
    }
    
    func showNewBorrow() {
        modal(factory.borrowEditViewController(delegate: self, type: viewModel.selectedBorrowType, borrowId: nil, expenseSourceFrom: nil, expenseSourceTo: nil))
    }
}

extension BorrowsViewController {
    
    @objc func loadData() {
        loadLoans()
        loadDebts()
    }
    
    private func loadLoans(finantialDataInvalidated: Bool = false) {
        if finantialDataInvalidated {
            postFinantialDataUpdated()
        }
        set(loansActivityIndicator, hidden: false, animated: false)
        firstly {
            viewModel.loadLoans()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки займов", theme: .error)
        }.finally {
            self.set(self.loansActivityIndicator, hidden: true)
            self.updateLoansUI()
        }
    }
    
    private func loadDebts(finantialDataInvalidated: Bool = false) {
        if finantialDataInvalidated {
            postFinantialDataUpdated()
        }
        set(debtsActivityIndicator, hidden: false, animated: false)
        firstly {
            viewModel.loadDebts()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки долгов", theme: .error)
        }.finally {
            self.set(self.debtsActivityIndicator, hidden: true)
            self.updateDebtsUI()
        }
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}

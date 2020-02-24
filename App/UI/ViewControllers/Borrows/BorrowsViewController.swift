//
//  BorrowsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import BetterSegmentedControl

class BorrowsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, ApplicationRouterDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: BorrowsViewModel!
    
    var debtsSupport: DebtsTableSupport?
    var loansSupport: LoansTableSupport?
    
    @IBOutlet weak var tabs: BetterSegmentedControl!
    
    @IBOutlet weak var loansActivityIndicator: UIView!
    @IBOutlet weak var debtsActivityIndicator: UIView!
    
    @IBOutlet weak var loansLoader: UIImageView!
    @IBOutlet weak var debtsLoader: UIImageView!
    
    @IBOutlet weak var loansContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var debtsContainerLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loansTableView: UITableView!
    @IBOutlet weak var debtsTableView: UITableView!
    
    private var tabsInitialized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        showNewBorrow()
    }
}

extension BorrowsViewController {
        
    func select(_ borrowType: BorrowType) {
        viewModel.selectedBorrowType = borrowType
        updateTabContentUI()
    }
    
    func setupUI() {
        setupTables()
        setupTabs()
        setupLoaders()        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTabs() {
        guard !tabsInitialized else { return }
        tabs.segments = LabelSegment.segments(withTitles: [NSLocalizedString("Я ДОЛЖЕН", comment: "Я ДОЛЖЕН"),
                                                           NSLocalizedString("МНЕ ДОЛЖНЫ", comment: "МНЕ ДОЛЖНЫ")],
                                              normalBackgroundColor: UIColor.clear,
                                              normalFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              normalTextColor: UIColor.by(.white100),
                                              selectedBackgroundColor: UIColor.by(.white12),
                                              selectedFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              selectedTextColor: UIColor.by(.white100))
        tabs.addTarget(self, action: #selector(didChangeTab), for: .valueChanged)
        tabsInitialized = true
    }
    
    @objc private func didChangeTab(_ sender: Any) {
        switch tabs.index {
        case 0:
            select(.loan)
        case 1:
            select(.debt)
        default:
            return
        }
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
        modal(factory.borrowInfoViewController(borrowId: nil, borrowType: nil, borrow: borrow))
    }
    
    func showNewBorrow() {
        modal(factory.borrowEditViewController(delegate: self, type: viewModel.selectedBorrowType, borrowId: nil, source: nil, destination: nil))
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
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки займов", comment: "Ошибка загрузки займов"), theme: .error)
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
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки долгов", comment: "Ошибка загрузки долгов"), theme: .error)
        }.finally {
            self.set(self.debtsActivityIndicator, hidden: true)
            self.updateDebtsUI()
        }
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}

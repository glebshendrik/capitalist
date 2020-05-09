//
//  BalanceViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import BetterSegmentedControl

class BalanceViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, ApplicationRouterDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    var viewModel: BalanceViewModel!
    
    lazy var expenseSourcesViewController: ExpenseSourcesViewController! = {
        return router.viewController(.ExpenseSourcesViewController) as! ExpenseSourcesViewController
    }()
    
    lazy var activesViewController: ActivesViewController! = {
        return router.viewController(.ActivesViewController) as! ActivesViewController
    }()
    
    @IBOutlet weak var tabs: BetterSegmentedControl!

    @IBOutlet weak var expenseSourcesContainer: UIView!
    @IBOutlet weak var activesContainer: UIView!
    
    @IBOutlet weak var expenseSourcesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var activesContainerLeftConstraint: NSLayoutConstraint!
        
    var tabsInitialized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    @objc func didTapAddButton(sender: Any) {
        switch viewModel.selectedBalanceCategory {
        case .expenseSources:
            expenseSourcesViewController.showNewExpenseSourceScreen()
        case .actives:
            activesViewController.showNewActiveScreen()
        }
    }
    
    func select(_ balanceCategory: BalanceCategory) {
        viewModel.selectedBalanceCategory = balanceCategory
        updateBalanceCategoryUI()
    }
    
    func setupUI() {
        setupNavigationBar()
        setupBalanceTabs()
        setupExpenseSourcesUI()
        setupActivesUI()
    }
    
    private func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.title = NSLocalizedString("Баланс", comment: "Баланс")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus-icon"), style: .plain, target: self, action: #selector(didTapAddButton(sender:)))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.by(.blue1)
    }
    
    private func setupExpenseSourcesUI() {
        addChild(expenseSourcesViewController)
        expenseSourcesContainer.addSubview(expenseSourcesViewController.view)
        expenseSourcesViewController.view.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        expenseSourcesViewController.didMove(toParent: self)
        expenseSourcesViewController.viewModel.shouldCalculateTotal = true
        expenseSourcesViewController.viewModel.isAddingAllowed = true
    }
    
    private func setupActivesUI() {
        addChild(activesViewController)
        activesContainer.addSubview(activesViewController.view)
        activesViewController.view.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        activesViewController.didMove(toParent: self)
        activesViewController.viewModel.shouldCalculateTotal = true
        activesViewController.viewModel.isAddingAllowed = true
    }
    
    private func setupBalanceTabs() {
        guard !tabsInitialized else { return }
        tabs.segments = LabelSegment.segments(withTitles: [NSLocalizedString("КОШЕЛЬКИ", comment: "КОШЕЛЬКИ"),
                                                           NSLocalizedString("АКТИВЫ", comment: "АКТИВЫ")],
                                              normalBackgroundColor: UIColor.clear,
                                              normalFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              normalTextColor: UIColor.by(.white100),
                                              selectedBackgroundColor: UIColor.by(.white12),
                                              selectedFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              selectedTextColor: UIColor.by(.white100))
        tabs.addTarget(self, action: #selector(didChangeBalanceTab(_:)), for: .valueChanged)
        tabsInitialized = true
    }
    
    @objc func didChangeBalanceTab(_ sender: Any) {
        switch tabs.index {
        case 0:
            select(.expenseSources)
        case 1:
            select(.actives)
        default:
            return
        }
    }
        
    func updateUI() {
        updateBalanceCategoryUI()
    }
    
    func updateBalanceCategoryUI() {
        
        func layoutPriorities(by balanceCategory: BalanceCategory) -> (expenseSourcesPriority: UILayoutPriority, activesPriority: UILayoutPriority) {
            
            let low = UILayoutPriority(integerLiteral: 998)
            let high = UILayoutPriority(integerLiteral: 999)
            
            switch balanceCategory {
            case .expenseSources:
                return (expenseSourcesPriority: high, activesPriority: low)
            case .actives:
                return (expenseSourcesPriority: low, activesPriority: high)
            }
        }
        
        let priorities = layoutPriorities(by: viewModel.selectedBalanceCategory)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.expenseSourcesContainerLeftConstraint.priority = priorities.expenseSourcesPriority
            self.activesContainerLeftConstraint.priority = priorities.activesPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

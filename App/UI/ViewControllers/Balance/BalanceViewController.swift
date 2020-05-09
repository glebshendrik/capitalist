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

class BalanceViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol, NavigationBarColorable, ApplicationRouterDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    var viewModel: BalanceViewModel!
    
    lazy var expenseSourcesViewController: ExpenseSourcesViewController! = {
        return router.viewController(.ExpenseSourcesViewController) as! ExpenseSourcesViewController
    }()
    
    var activesSupport: BalanceActivesTableSupport?
    
    @IBOutlet weak var tabs: BetterSegmentedControl!

    @IBOutlet weak var expenseSourcesContainer: UIView!
    
    @IBOutlet weak var activesActivityIndicator: UIView!
    @IBOutlet weak var activesLoader: UIImageView!
    
    @IBOutlet weak var expenseSourcesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var activesContainerLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activesTableView: UITableView!
    
    @IBOutlet weak var activesAmountLabel: UILabel!
    
    var tabsInitialized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        embedChildren()
        setupExpenseSourcesUI()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    private func embedChildren() {
        embedExpenseSources()
    }
    
    private func embedExpenseSources() {
        addChild(expenseSourcesViewController)
        expenseSourcesContainer.addSubview(expenseSourcesViewController.view)
        expenseSourcesViewController.view.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        expenseSourcesViewController.didMove(toParent: self)
    }
    
    private func setupExpenseSourcesUI() {
        expenseSourcesViewController.viewModel.shouldCalculateTotal = true
        expenseSourcesViewController.viewModel.isAddingAllowed = true
    }
}

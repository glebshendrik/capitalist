//
//  BalanceViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class BalanceViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, ApplicationRouterDependantProtocol, NavigationBarColorable {
        
    var navigationBarTintColor: UIColor? = UIColor.by(.dark333D5B)
    var router: ApplicationRouterProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: BalanceViewModel!
    
    var expenseSourcesSupport: BalanceExpenseSourcesTableSupport?
    var expenseCategoriesSupport: BalanceExpenseCategoriesTableSupport?
    
    @IBOutlet weak var expenseSourcesLabel: UILabel!
    @IBOutlet weak var expenseCategoriesLabel: UILabel!
    
    @IBOutlet weak var expenseSourcesSelectionIndicator: UIView!
    @IBOutlet weak var expenseCategoriesSelectionIndicator: UIView!
    
    @IBOutlet weak var expenseSourcesActivityIndicator: UIView!
    @IBOutlet weak var expenseCategoriesActivityIndicator: UIView!
    
    @IBOutlet weak var expenseSourcesLoader: UIImageView!
    @IBOutlet weak var expenseCategoriesLoader: UIImageView!
    
    @IBOutlet weak var expenseSourcesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var expenseCategoriesContainerLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var expenseSourcesTableView: UITableView!
    @IBOutlet weak var expenseCategoriesTableView: UITableView!
    
    @IBOutlet weak var expenseSourcesAmountLabel: UILabel!
    @IBOutlet weak var expenseCategoriesAmountLabel: UILabel!
    
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
    
    @IBAction func didTapExpenseSources(_ sender: Any) {
        select(.expenseSources)
    }
    
    @IBAction func didTapExpenseCategories(_ sender: Any) {
        select(.expenseCategories)
    }
}

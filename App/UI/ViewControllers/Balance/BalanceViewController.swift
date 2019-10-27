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
    var activesSupport: BalanceActivesTableSupport?
    
    @IBOutlet weak var expenseSourcesLabel: UILabel!
    @IBOutlet weak var activesLabel: UILabel!
    
    @IBOutlet weak var expenseSourcesSelectionIndicator: UIView!
    @IBOutlet weak var activesSelectionIndicator: UIView!
    
    @IBOutlet weak var expenseSourcesActivityIndicator: UIView!
    @IBOutlet weak var activesActivityIndicator: UIView!
    
    @IBOutlet weak var expenseSourcesLoader: UIImageView!
    @IBOutlet weak var activesLoader: UIImageView!
    
    @IBOutlet weak var expenseSourcesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var activesContainerLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var expenseSourcesTableView: UITableView!
    @IBOutlet weak var activesTableView: UITableView!
    
    @IBOutlet weak var expenseSourcesAmountLabel: UILabel!
    @IBOutlet weak var activesAmountLabel: UILabel!
    
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
    
    @IBAction func didTapActives(_ sender: Any) {
        select(.actives)
    }
}

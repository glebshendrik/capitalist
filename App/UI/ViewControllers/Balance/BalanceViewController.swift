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

class BalanceViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: BalanceViewModel!
    
    var expenseSourcesSupport: BalanceExpenseSourcesTableSupport?
    var activesSupport: BalanceActivesTableSupport?
    
    
    @IBOutlet weak var tabs: BetterSegmentedControl!
    
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
    
    var tabsInitialized: Bool = false
    
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
}

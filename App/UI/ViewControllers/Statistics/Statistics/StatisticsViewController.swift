//
//  StatisticsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class StatisticsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.dark333D5B)
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: StatisticsViewModel!
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    var titleView: StatisticsTitleView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    
    @IBOutlet weak var incomesContainer: UIView!
    @IBOutlet weak var expensesContainer: UIView!
    
    @IBOutlet weak var incomesAmountLabel: UILabel!
    @IBOutlet weak var expensesAmountLabel: UILabel!
    @IBOutlet weak var filtersHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var footerOverlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData(financialDataInvalidated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.by(.dark333D5B)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()        
    }
}

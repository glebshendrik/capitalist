//
//  StatisticsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import BadgeHub

class StatisticsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: StatisticsViewModel!
    var factory: UIFactoryProtocol!
    var titleView: StatisticsTitleView!
    
    @IBOutlet weak var tableView: UITableView!
    var filtersBadge: BadgeHub? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData(financialDataInvalidated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

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
import EasyTipView

class StatisticsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: StatisticsViewModel!
    var factory: UIFactoryProtocol!
    var titleView: StatisticsTitleView!
    
    @IBOutlet weak var tableView: UITableView!
    var filtersBadge: BadgeHub? = nil
    
    @IBOutlet weak var mainOverlay: UIView!
    @IBOutlet weak var rangeTutorialAnchor: UIView!
    @IBOutlet weak var filtersTutorialAnchor: UIView!
    weak var tutorialTip: EasyTipView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.updatePeriods()
        loadData(financialDataInvalidated: false)
//        UIFlowManager.set(point: .statisticsPeriodTutorial, reached: false)
//        UIFlowManager.set(point: .statisticsFiltersTutorial, reached: false)
        after(seconds: 0.7).done {
            self.show(self.tutorials)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deinitTip()
    }
    
    @IBAction func didTapMainOverlay(_ sender: Any) {
        tutorialTip?.dismiss()
        setMainOverlay(hidden: true)
    }
    
    deinit {
        deinitTip()
        NotificationCenter.default.removeObserver(self)
    }
    
    func deinitTip() {
        let tip = tutorialTip
        tutorialTip = nil
        tip?.dismiss()
        setMainOverlay(hidden: true)
    }
}

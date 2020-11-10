//
//  MainViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SideMenu
import PromiseKit
import SwifterSwift
import BetterSegmentedControl
import EasyTipView

class MainViewController : UIViewController,
                           UIMessagePresenterManagerDependantProtocol,
                           NavigationBarColorable,
                           UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    
    var viewModel: MainViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    var soundsManager: SoundsManagerProtocol!
    var longPressureRecognizers: [UILongPressGestureRecognizer] = []
    var transactionRecognizer: UILongPressGestureRecognizer? = nil
    
    static var finantialDataInvalidatedNotification = NSNotification.Name("finantialDataInvalidatedNotification")
    
    @IBOutlet weak var expenseSourcesCollectionView: UICollectionView!
    @IBOutlet weak var expenseSourcesActivityIndicator: UIView!
    @IBOutlet weak var expenseSourcesLoader: UIImageView!
    @IBOutlet weak var expenseSourcesAmountLabel: UILabel!
    
    @IBOutlet weak var basketsContentScrollView: UIScrollView!
    @IBOutlet weak var basketsTabs: BetterSegmentedControl!
    var tabsInitialized: Bool = false
    
    @IBOutlet weak var joyExpenseCategoriesCollectionView: UICollectionView!
    @IBOutlet weak var riskActivesCollectionView: UICollectionView!
    @IBOutlet weak var safeActivesCollectionView: UICollectionView!
    
    @IBOutlet weak var joyExpenseCategoriesActivityIndicator: UIView!
    @IBOutlet weak var joyExpenseCategoriesLoader: UIImageView!
    
    @IBOutlet weak var riskActivesActivityIndicator: UIView!
    @IBOutlet weak var riskActivesLoader: UIImageView!
    
    @IBOutlet weak var safeActivesActivityIndicator: UIView!
    @IBOutlet weak var safeActivesLoader: UIImageView!
    
    @IBOutlet weak var transactionDraggingElement: UIView!    
    @IBOutlet weak var basketTotalLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var mainButtonBackground: UIView!
    @IBOutlet weak var mainButtonTopToBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var plusMenu: FanMenu!
    @IBOutlet weak var plusOverlay: UIView!
    @IBOutlet weak var mainOverlay: UIView!
    
    var titleView: TitleView!
    var transactionController: TransactionController!
    var rearrangeController: RearrangeController!
    var adviserTip: EasyTipView?
    
    var tutorialTip: EasyTipView?
    @IBOutlet weak var menuTutorialAnchor: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
//        UIFlowManager.set(point: .incomeSourcesTutorial, reached: false)
//        UIFlowManager.set(point: .debtsAndCreditsTutorial, reached: false)
//        UIFlowManager.set(point: .settingsTutorial, reached: false)
        show(tutorials)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
        appMovedToForeground()
        updateLongPressureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIFlowManager.reached(point: .transactionCreationInfoMessage) {
            modal(factory.transactionCreationInfoViewController())
        }
        adviserTip?.show(animated: true, forView: titleView.tipAnchor, withinSuperview: titleView)
        checkAppUpdateNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        adviserTip?.dismiss()
    }
    
    @IBAction func didTapMainButton(_ sender: Any) {
        tapMainButton()
    }
    
    @IBAction func didTapExpenseSources(_ sender: Any) {
        showBalance()
    }
    
    @IBAction func didTapStatistics(_ sender: Any) {
        showStatistics(with: nil)
    }
    
    
    @IBAction func didTapInfoButton(_ sender: Any) {
        modal(factory.transactionCreationInfoViewController())
    }
    
    @IBAction func didTapPlusMenuOverlay(_ sender: Any) {        
        plusMenu.close()
        setMenuOverlay(hidden: true)
    }
    
    @IBAction func didTapMainOverlay(_ sender: Any) {
        tutorialTip?.dismiss()
        setMainOverlay(hidden: true)
    }
    
    deinit {        
        NotificationCenter.default.removeObserver(self)
    }
}

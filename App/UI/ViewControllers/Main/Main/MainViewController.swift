//
//  MainViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SideMenu
import PromiseKit
import SwifterSwift

class MainViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.dark2A314B)
    
    var viewModel: MainViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    var soundsManager: SoundsManagerProtocol!
    var longPressureRecognizers: [UILongPressGestureRecognizer] = []
    
    static var finantialDataInvalidatedNotification = NSNotification.Name("finantialDataInvalidatedNotification")
    
    @IBOutlet weak var incomeSourcesCollectionView: UICollectionView!
    @IBOutlet weak var incomeSourcesActivityIndicator: UIView!
    @IBOutlet weak var incomeSourcesLoader: UIImageView!
    
    @IBOutlet weak var expenseSourcesCollectionView: UICollectionView!
    @IBOutlet weak var expenseSourcesActivityIndicator: UIView!
    @IBOutlet weak var expenseSourcesLoader: UIImageView!
    
    @IBOutlet weak var joyBasketProgressConstraint: NSLayoutConstraint!
    @IBOutlet weak var riskBasketProgressConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeBasketProgressConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var joyBasketSpentLabel: UILabel!
    @IBOutlet weak var joyBasketTitleLabel: UILabel!
    
    @IBOutlet weak var riskBasketSpentLabel: UILabel!
    @IBOutlet weak var riskBasketTitleLabel: UILabel!
    
    @IBOutlet weak var safeBasketSpentLabel: UILabel!
    @IBOutlet weak var safeBasketTitleLabel: UILabel!
    
    @IBOutlet weak var joyExpenseCategoriesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var riskExpenseCategoriesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeExpenseCategoriesLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var joyExpenseCategoriesCollectionView: UICollectionView!
    @IBOutlet weak var riskExpenseCategoriesCollectionView: UICollectionView!
    @IBOutlet weak var safeExpenseCategoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var joyExpenseCategoriesActivityIndicator: UIView!
    @IBOutlet weak var joyExpenseCategoriesLoader: UIImageView!
    @IBOutlet weak var joyExpenseCategoriesPageControl: UIPageControl!
    
    @IBOutlet weak var riskExpenseCategoriesActivityIndicator: UIView!
    @IBOutlet weak var riskExpenseCategoriesLoader: UIImageView!
    @IBOutlet weak var riskExpenseCategoriesPageControl: UIPageControl!
    
    @IBOutlet weak var safeExpenseCategoriesActivityIndicator: UIView!
    @IBOutlet weak var safeExpenseCategoriesLoader: UIImageView!
    @IBOutlet weak var safeExpenseCategoriesPageControl: UIPageControl!
    
    @IBOutlet weak var transactionDraggingElement: UIView!

    @IBOutlet weak var editDoneButton: UIButton!
    @IBOutlet weak var editDoneButtonHeightConstraint: NSLayoutConstraint!
    
    var budgetView: BudgetView!
    var transactionController: TransactionController!
    var rearrangeController: RearrangeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.navigationBar.barTintColor = UIColor.by(.dark2A314B)
        appMovedToForeground()
    }
    
    @IBAction func didTapJoyBasket(_ sender: Any) {
        didTapBasket(with: .joy)
    }
    
    @IBAction func didTapRiskBasket(_ sender: Any) {
        didTapBasket(with: .risk)
    }
    
    @IBAction func didTapSafeBasket(_ sender: Any) {
        didTapBasket(with: .safe)
    }
    
    @IBAction func didTapEditDoneButton(_ sender: Any) {
        setEditing(false, animated: true)
    }
}

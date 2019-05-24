//
//  SettingUpExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SideMenu

extension MainViewController {
    func setupUI() {
        setupIncomeSourcesCollectionView()
        setupExpenseSourcesCollectionView()
        setupExpenseCategoriesCollectionView()
        setupNavigationBar()
        setupMainMenu()
        setupLoaders()
        setupGestureRecognizers()
        setupNotifications()
        setupTransactionController()
        setupRearrangeController()
    }
    
    private func setupIncomeSourcesCollectionView() {
        incomeSourcesCollectionView.delegate = self
        incomeSourcesCollectionView.dataSource = self
    }
    
    private func setupExpenseSourcesCollectionView() {
        expenseSourcesCollectionView.delegate = self
        expenseSourcesCollectionView.dataSource = self
    }
    
    private func setupExpenseCategoriesCollectionView() {
        joyExpenseCategoriesCollectionView.delegate = self
        joyExpenseCategoriesCollectionView.dataSource = self
        
        riskExpenseCategoriesCollectionView.delegate = self
        riskExpenseCategoriesCollectionView.dataSource = self
        
        safeExpenseCategoriesCollectionView.delegate = self
        safeExpenseCategoriesCollectionView.dataSource = self
        
        updateExpenseCategoriesPageControl(by: .joy)
        updateExpenseCategoriesPageControl(by: .risk)
        updateExpenseCategoriesPageControl(by: .safe)
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.init(red: 48 / 255.0,
                                                                                green: 53 / 255.0,
                                                                                blue: 79 / 255.0,
                                                                                alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.budgetView = BudgetView(frame: CGRect.zero)
        self.budgetView.delegate = self
        navigationItem.titleView = self.budgetView
    }
    
    private func setupMainMenu() {
        //        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        //        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    private func setupLoaders() {
        incomeSourcesLoader.showLoader()
        expenseSourcesLoader.showLoader()
        joyExpenseCategoriesLoader.showLoader()
        riskExpenseCategoriesLoader.showLoader()
        safeExpenseCategoriesLoader.showLoader()
        set(incomeSourcesActivityIndicator, hidden: true, animated: false)
        set(expenseSourcesActivityIndicator, hidden: true, animated: false)
        set(joyExpenseCategoriesActivityIndicator, hidden: true, animated: false)
        set(riskExpenseCategoriesActivityIndicator, hidden: true, animated: false)
        set(safeExpenseCategoriesActivityIndicator, hidden: true, animated: false)
    }
    
    private func setupGestureRecognizers() {
        setupRearrangeGestureRecognizer(for: incomeSourcesCollectionView)
        setupRearrangeGestureRecognizer(for: expenseSourcesCollectionView)
        setupRearrangeGestureRecognizer(for: joyExpenseCategoriesCollectionView)
        setupRearrangeGestureRecognizer(for: riskExpenseCategoriesCollectionView)
        setupRearrangeGestureRecognizer(for: safeExpenseCategoriesCollectionView)
        setupTransactionGestureRecognizer()
    }
    
    private func setupRearrangeGestureRecognizer(for collectionView: UICollectionView) {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeRearrangeGesture(gesture:)))
        collectionView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.95
    }
    
    private func setupTransactionGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeTransactionGesture(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.0525
        gestureRecognizer.delegate = self
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finantialDataInvalidated), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTransactionController() {
        transactionController = TransactionController(delegate: self)
    }
    
    private func setupRearrangeController() {
        rearrangeController = RearrangeController()
    }
}

extension MainViewController {
    func layoutUI() {
        layoutExpenseCategoriesCollectionView(by: .joy)
        layoutExpenseCategoriesCollectionView(by: .risk)
        layoutExpenseCategoriesCollectionView(by: .safe)
        layoutIncomeSourcesCollectionView()
        layoutExpenseSourcesCollectionView()
    }
    
    private func layoutExpenseCategoriesCollectionView(by basketType: BasketType) {
        let collectionView = expenseCategoriesCollectionView(by: basketType)
        if let layout = collectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.itemSize = CGSize(width: 68, height: 109)
            layout.columns = 4
            layout.rows = Int(collectionView.bounds.size.height / layout.itemSize.height)
            layout.edgeInsets = UIEdgeInsets(horizontal: 30, vertical: 5)
        }
    }
    
    private func layoutIncomeSourcesCollectionView() {
        fillLayout(collectionView: incomeSourcesCollectionView,
                   itemHeight: 56.0,
                   innerSpace: 2.0,
                   outerSpace: 8.0,
                   columns: 3)
    }
    
    private func layoutExpenseSourcesCollectionView() {
        fillLayout(collectionView: expenseSourcesCollectionView,
                   itemHeight: 62.0,
                   innerSpace: 2.0,
                   outerSpace: 8.0,
                   columns: 2)
    }
    
    private func fillLayout(collectionView: UICollectionView,
                            itemHeight: CGFloat,
                            innerSpace: CGFloat,
                            outerSpace: CGFloat,
                            columns: Int) {
        
        if let layout = collectionView.collectionViewLayout as? PagedCollectionViewLayout {
            
            let containerWidth = incomeSourcesCollectionView.bounds.size.width
            
            layout.columns = columns
            layout.rows = 1
            layout.edgeInsets = UIEdgeInsets(horizontal: outerSpace * 2, vertical: 0)
            
            let width = CGFloat(containerWidth - layout.edgeInsets.horizontal - CGFloat(layout.columns - 1) * innerSpace) / CGFloat(layout.columns)
            
            layout.itemSize = CGSize(width: width, height: itemHeight)
        }
    }
}

extension MainViewController {
    @objc func appMovedToForeground() {
        setVisibleCells(editing: isEditing)
    }
}

extension MainViewController {
    @objc func finantialDataInvalidated() {
        loadData()
    }
}

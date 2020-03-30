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
    var fastPressDuration: TimeInterval {
        return 0.0525
    }
    
    var slowPressDuration: TimeInterval {
        return 0.6
    }
    
    func setupUI() {
        setupIncomeSourcesCollectionView()
        setupExpenseSourcesCollectionView()
        setupBasketsItemsCollectionView()
        setupBasketsTabs()
        setupNavigationBar()
        setupMainMenu()
        setupLoaders()
        setupGestureRecognizers()
        setupNotifications()
        setupTransactionController()
        setupRearrangeController()
        updateMainButtonUI()
    }
    
    private func setupIncomeSourcesCollectionView() {
        incomeSourcesCollectionView.delegate = self
        incomeSourcesCollectionView.dataSource = self
    }
    
    private func setupExpenseSourcesCollectionView() {
        expenseSourcesCollectionView.delegate = self
        expenseSourcesCollectionView.dataSource = self
    }
    
    private func setupBasketsItemsCollectionView() {
        joyExpenseCategoriesCollectionView.delegate = self
        joyExpenseCategoriesCollectionView.dataSource = self
        
        riskActivesCollectionView.delegate = self
        riskActivesCollectionView.dataSource = self
        
        safeActivesCollectionView.delegate = self
        safeActivesCollectionView.dataSource = self
        
        basketsContentScrollView.delegate = self
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18)!,
                          NSAttributedString.Key.foregroundColor : UIColor.by(.white100)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()        
        self.titleView = TitleView(frame: CGRect.zero)
        self.titleView.delegate = self
        navigationItem.titleView = self.titleView
    }
    
    private func setupMainMenu() {
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.incomeSourcesCollectionView)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.expenseSourcesCollectionView)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.basketsContentScrollView)        
    }
    
    private func setupLoaders() {
        incomeSourcesLoader.showLoader()
        expenseSourcesLoader.showLoader()
        joyExpenseCategoriesLoader.showLoader()
        riskActivesLoader.showLoader()
        safeActivesLoader.showLoader()
        set(incomeSourcesActivityIndicator, hidden: true, animated: false)
        set(expenseSourcesActivityIndicator, hidden: true, animated: false)
        set(joyExpenseCategoriesActivityIndicator, hidden: true, animated: false)
        set(riskActivesActivityIndicator, hidden: true, animated: false)
        set(safeActivesActivityIndicator, hidden: true, animated: false)
    }
    
    private func setupGestureRecognizers() {
        setupRearrangeGestureRecognizer(for: incomeSourcesCollectionView)
        setupRearrangeGestureRecognizer(for: expenseSourcesCollectionView)
        setupRearrangeGestureRecognizer(for: joyExpenseCategoriesCollectionView)
        setupRearrangeGestureRecognizer(for: riskActivesCollectionView)
        setupRearrangeGestureRecognizer(for: safeActivesCollectionView)
        setupTransactionGestureRecognizer()
    }
    
    private func setupRearrangeGestureRecognizer(for collectionView: UICollectionView) {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeRearrangeGesture(gesture:)))
        collectionView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = slowPressDuration
        gestureRecognizer.delegate = self
        longPressureRecognizers.append(gestureRecognizer)
    }
    
    private func setupTransactionGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeTransactionGesture(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = fastPressDuration
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
        layoutBasketItems(collectionView: joyExpenseCategoriesCollectionView)
        layoutBasketItems(collectionView: riskActivesCollectionView)
        layoutBasketItems(collectionView: safeActivesCollectionView)
        layoutIncomeSourcesCollectionView()
        layoutExpenseSourcesCollectionView()
    }
    
    private func layoutBasketItems(collectionView: UICollectionView) {
        columnsPagedLayout(collectionView: collectionView,
                           columns: 4,
                           itemHeight: 120,
                           horizontalInset: 30,
                           verticalInset: 6)
    }
    
    
    private func layoutIncomeSourcesCollectionView() {
        fillLayout(collectionView: incomeSourcesCollectionView,
                   itemHeight: 48.0,
                   innerSpace: 2.0,
                   outerSpace: 1.0,
                   columns: 3)
    }
    
    private func layoutExpenseSourcesCollectionView() {
        fillLayout(collectionView: expenseSourcesCollectionView,
                   itemHeight: 68.0,
                   innerSpace: 2.0,
                   outerSpace: 1.0,
                   columns: 3)
    }
    
    private func columnsPagedLayout(collectionView: UICollectionView,
                                    columns: Int,
                                    itemHeight: CGFloat,
                                    horizontalInset: CGFloat,
                                    verticalInset: CGFloat) {
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let verticalSpace = collectionView.bounds.size.height - verticalInset
            let rows = Int(verticalSpace / itemHeight)
            let fillItemHeight = verticalSpace / CGFloat(rows)
            
            let horizontalSpace = collectionView.bounds.width - horizontalInset * 2
            let fillItemWidth = horizontalSpace / CGFloat(columns)
            
            let height = rows == 1 ? itemHeight : fillItemHeight
            
            layout.itemSize = CGSize(width: fillItemWidth, height: height)
            layout.sectionInset = UIEdgeInsets(horizontal: horizontalInset, vertical: verticalInset)
            layout.minimumLineSpacing = 0
        }
    }
    
    private func fillLayout(collectionView: UICollectionView,
                            itemHeight: CGFloat,
                            innerSpace: CGFloat,
                            outerSpace: CGFloat,
                            columns: Int,
                            leftInset: CGFloat = 10) {
        
        if let layout = collectionView.collectionViewLayout as? PagedCollectionViewLayout {
            
            let containerWidth = collectionView.bounds.size.width
            
            layout.columns = columns
            layout.rows = 1
            layout.edgeInsets = UIEdgeInsets(horizontal: outerSpace * 2, vertical: 0)
            layout.sectionEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: containerWidth * 0.333 - outerSpace)
            let width = CGFloat(containerWidth - layout.edgeInsets.horizontal - CGFloat(layout.columns - 1) * innerSpace) / CGFloat(layout.columns)
            
            layout.itemSize = CGSize(width: width, height: itemHeight)
        }
    }
}
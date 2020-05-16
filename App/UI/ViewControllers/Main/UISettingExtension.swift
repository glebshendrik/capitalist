//
//  SettingUpExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SideMenu
import Macaw

extension MainViewController {
    var fastPressDuration: TimeInterval {
        return viewModel.fastGesturePressDuration
    }
    
    var slowPressDuration: TimeInterval {
        return fastPressDuration + 1.0
    }
    
    func setupUI() {
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
        setupPlusMenu()
    }
        
    private func setupPlusMenu() {
        let main = UIColor.by(.blue1).rgbComponents
        plusMenu.button = FanMenuButton(
            id: "main",
            image: "main-plus",
            color: Color.rgb(r: main.red, g: main.green, b: main.blue)
        )
        
        let color = Color.rgba(r: 234, g: 238, b: 244, a: 0.06)
        let title = UIColor.by(.white100).rgbComponents
        let titleColor = Color.rgb(r: title.red, g: title.green, b: title.blue)
        
        plusMenu.items = [
            FanMenuButton(
                id: "income",
                image: "income-menu-item-icon",
                color: color,
                title: NSLocalizedString("Доход", comment: "Доход"),
                titleColor: titleColor
            ),
            FanMenuButton(
                id: "funds_move",
                image: "funds-move-menu-item-icon",
                color: color,
                title: NSLocalizedString("Перевод", comment: "Перевод"),
                titleColor: titleColor
            ),
            FanMenuButton(
                id: "expense",
                image: "expense-menu-item-icon",
                color: color,
                title: NSLocalizedString("Расход", comment: "Расход"),
                titleColor: titleColor
            )
        ]
        
        plusMenu.menuRadius = 200.0
        plusMenu.radius = 29.0
        plusMenu.duration = 0.2
        plusMenu.delay = 0
        let startInterval: Double = UIDevice.current.hasNotch ? .pi : (.pi + .pi / 20)
        plusMenu.interval = (startInterval, .pi + .pi / 2)
        plusMenu.buttonsTitleIndent = 12

        let brand = UIColor.by(.brandExpense).rgbComponents
        plusMenu.menuBackground = Color.rgb(r: brand.red, g: brand.green, b: brand.blue).with(a: 0.98)
        plusMenu.backgroundColor = .clear
        plusMenu.onItemWillClick = { button in
            self.didTapPlusMenu(buttonId: button.id)
            self.setMenuOverlay(hidden: self.plusMenu.isOpen)
        }
    }
    
    func didTapPlusMenu(buttonId: String) {
        switch buttonId {
        case "income":
            showTransactionEditScreen(transactionType: .income)
        case "funds_move":
            showTransactionEditScreen(transactionType: .fundsMove)
        case "expense":
            showTransactionEditScreen(transactionType: .expense)
        default:
            return
        }
    }
    
    func setMenuOverlay(hidden: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = hidden ? 0 : -1
        self.navigationController?.navigationBar.isUserInteractionEnabled = hidden
        let newValue: CGFloat = hidden ? 0.0 : 0.5
        UIView.animate(withDuration: 0.2, animations: {
            self.plusOverlay.alpha = newValue
        })
        view.haptic()
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
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.expenseSourcesCollectionView)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.basketsContentScrollView)        
    }
    
    private func setupLoaders() {
        expenseSourcesLoader.showLoader()
        joyExpenseCategoriesLoader.showLoader()
        riskActivesLoader.showLoader()
        safeActivesLoader.showLoader()
        set(expenseSourcesActivityIndicator, hidden: true, animated: false)
        set(joyExpenseCategoriesActivityIndicator, hidden: true, animated: false)
        set(riskActivesActivityIndicator, hidden: true, animated: false)
        set(safeActivesActivityIndicator, hidden: true, animated: false)
    }
    
    private func setupGestureRecognizers() {
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
        transactionRecognizer = gestureRecognizer
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
        layoutExpenseSourcesCollectionView()
    }
    
    private func layoutBasketItems(collectionView: UICollectionView) {
        columnsPagedLayout(collectionView: collectionView,
                           columns: 4,
                           itemHeight: 120,
                           horizontalInset: 30,
                           verticalInset: 6)
    }
    
    private func layoutExpenseSourcesCollectionView() {
        fillLayout(collectionView: expenseSourcesCollectionView,
                   itemHeight: 96.0,
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
            
            let height = rows == 2 ? itemHeight : fillItemHeight
            
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
//            let width = CGFloat(containerWidth - layout.edgeInsets.horizontal - CGFloat(layout.columns - 1) * innerSpace) / CGFloat(layout.columns)
            let width: CGFloat = 161.0
            layout.itemSize = CGSize(width: width, height: itemHeight)
        }
    }
}

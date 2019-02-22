//
//  MainViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import SideMenu
import PromiseKit
import SwifterSwift

class MainViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    var viewModel: MainViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var router: ApplicationRouterProtocol!
    
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
    @IBOutlet weak var joyBasketSelectionIndicator: UIView!
    
    @IBOutlet weak var riskBasketSpentLabel: UILabel!
    @IBOutlet weak var riskBasketTitleLabel: UILabel!
    @IBOutlet weak var riskBasketSelectionIndicator: UIView!
    
    @IBOutlet weak var safeBasketSpentLabel: UILabel!
    @IBOutlet weak var safeBasketTitleLabel: UILabel!
    @IBOutlet weak var safeBasketSelectionIndicator: UIView!
    
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
    
    private var movingIndexPath: IndexPath? = nil
    private var movingCollectionView: UICollectionView? = nil
    private var offsetForCollectionViewCellBeingMoved: CGPoint = .zero
    
    private var transactionStartedCollectionView: UICollectionView? = nil
    private var transactionStartedCell: UICollectionViewCell? = nil
    private var dropCandidateCell: UICollectionViewCell? = nil
    @IBOutlet weak var transactionDraggingElement: UIView!

    @IBOutlet weak var editDoneButton: UIButton!
    @IBOutlet weak var editDoneButtonHeightConstraint: NSLayoutConstraint!
    
    var isTransactionStarted: Bool {
        return transactionStartedCollectionView != nil
    }
    
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
        navigationController?.navigationBar.barTintColor = UIColor.mainNavBarColor
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
    private func didTapBasket(with basketType: BasketType) {
        viewModel.basketsViewModel.selectBasketBy(basketType: basketType)
        updateBasketsUI()
    }
    
    private func loadData() {
        loadIncomeSources()
        loadExpenseSources()
        loadBaskets()
        loadExpenseCategories(by: .joy)
        loadExpenseCategories(by: .risk)
        loadExpenseCategories(by: .safe)
    }
}

extension MainViewController {
    private func updateBasketsUI() {
        updateBasketsRatiosUI()
        updateBasketsTabsUI()
        updateBasketExpenseCategoriesContainer()
    }
    
    private func updateBasketsRatiosUI() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.joyBasketProgressConstraint = self.joyBasketProgressConstraint.setMultiplier(multiplier: self.viewModel.basketsViewModel.joyBasketRatio)
            
            self.riskBasketProgressConstraint = self.riskBasketProgressConstraint.setMultiplier(multiplier: self.viewModel.basketsViewModel.riskBasketRatio)
            
            self.safeBasketProgressConstraint = self.safeBasketProgressConstraint.setMultiplier(multiplier: self.viewModel.basketsViewModel.safeBasketRatio)
            
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    private func updateBasketsTabsUI() {
        let selectedTextColor = UIColor(red: 0.25, green: 0.27, blue: 0.38, alpha: 1)
        let unselectedTextColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.joyBasketSpentLabel.text = self.viewModel.basketsViewModel.joyBasketMonthlySpent
            self.joyBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isJoyBasketSelected ? selectedTextColor : unselectedTextColor
            self.joyBasketSelectionIndicator.isHidden = !self.viewModel.basketsViewModel.isJoyBasketSelected
            
            self.riskBasketSpentLabel.text = self.viewModel.basketsViewModel.riskBasketMonthlySpent
            self.riskBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isRiskBasketSelected ? selectedTextColor : unselectedTextColor
            self.riskBasketSelectionIndicator.isHidden = !self.viewModel.basketsViewModel.isRiskBasketSelected
            
            self.safeBasketSpentLabel.text = self.viewModel.basketsViewModel.safeBasketMonthlySpent
            self.safeBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isSafeBasketSelected ? selectedTextColor : unselectedTextColor
            self.safeBasketSelectionIndicator.isHidden = !self.viewModel.basketsViewModel.isSafeBasketSelected
        })
    }
    
    private func updateBasketExpenseCategoriesContainer() {
        let lowPriority = UILayoutPriority(integerLiteral: 998)
        let highPriority = UILayoutPriority(integerLiteral: 999)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.joyExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isJoyBasketSelected ? highPriority : lowPriority
            self.riskExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isRiskBasketSelected ? highPriority : lowPriority
            self.safeExpenseCategoriesLeftConstraint.priority = self.viewModel.basketsViewModel.isSafeBasketSelected ? highPriority : lowPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func loadBaskets() {
//        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadBaskets()
        }.done {
            self.updateBasketsUI()
        }
        .catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки корзин", theme: .error)
        }.finally {
//            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
}

extension MainViewController : IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource() {
        loadIncomeSources()
    }
    
    func didUpdateIncomeSource() {
        loadIncomeSources()
    }
    
    func didRemoveIncomeSource() {
        loadIncomeSources()
    }
    
    private func loadIncomeSources(scrollToEndWhenUpdated: Bool = false) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadIncomeSources()
        }.done {
            self.update(self.incomeSourcesCollectionView,
                        scrollToEnd: scrollToEndWhenUpdated)
        }
        .catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки источников доходов", theme: .error)
        }.finally {
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
    
    private func didSelectIncomeSource(at indexPath: IndexPath) {
        guard viewModel.isAddIncomeSourceItem(indexPath: indexPath) else { return }
        
        showNewIncomeSourceScreen()
    }
    
    private func showNewIncomeSourceScreen() {
        showEditScreen(incomeSource: nil)
    }
    
    private func showEditScreen(incomeSource: IncomeSource?) {
        if  let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController,
            let incomeSourceEditViewController = incomeSourceEditNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
            incomeSourceEditViewController.set(delegate: self)
            
            if let incomeSource = incomeSource {
                incomeSourceEditViewController.set(incomeSource: incomeSource)
            }
            
            present(incomeSourceEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func incomeSourceCollectionViewCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if viewModel.isAddIncomeSourceItem(indexPath: indexPath) {
            return incomeSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "AddIncomeSourceCollectionViewCell",
                                                                   for: indexPath)
        }
        
        guard let cell = incomeSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "IncomeSourceCollectionViewCell",
                                                            for: indexPath) as? IncomeSourceCollectionViewCell,
            let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = incomeSourceViewModel
        return cell
    }
    
    private func moveIncomeSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.moveIncomeSource(from: sourceIndexPath,
                                   to: destinationIndexPath)
        }.done {
            self.update(self.incomeSourcesCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка источников доходов", theme: .error)
        }.finally {
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
    
    private func removeIncomeSource(by id: Int) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.removeIncomeSource(by: id)
        }.done {
            self.update(self.incomeSourcesCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления источника дохода", theme: .error)
        }.finally {
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
}

extension MainViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        loadExpenseSources()
    }
    
    func didUpdateExpenseSource() {
        loadExpenseSources()
    }
    
    func didRemoveExpenseSource() {
        loadExpenseSources()
    }
    
    private func loadExpenseSources(scrollToEndWhenUpdated: Bool = false) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadExpenseSources()
        }.done {
            self.update(self.expenseSourcesCollectionView,
                        scrollToEnd: scrollToEndWhenUpdated)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки источников трат", theme: .error)
        }.finally {
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
        }
    }
    
    private func didSelectExpenseSource(at indexPath: IndexPath) {
        guard viewModel.isAddExpenseSourceItem(indexPath: indexPath) else { return }
        showNewExpenseSourceScreen()
    }
    
    private func showNewExpenseSourceScreen() {
        showEditScreen(expenseSource: nil)
    }
    
    private func showEditScreen(expenseSource: ExpenseSource?) {
        if  let expenseSourceEditNavigationController = router.viewController(.ExpenseSourceEditNavigationController) as? UINavigationController,
            let expenseSourceEditViewController = expenseSourceEditNavigationController.topViewController as? ExpenseSourceEditInputProtocol {
            
            expenseSourceEditViewController.set(delegate: self)
            
            if let expenseSource = expenseSource {
                expenseSourceEditViewController.set(expenseSource: expenseSource)
            }
            
            present(expenseSourceEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func expenseSourceCollectionViewCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.isAddExpenseSourceItem(indexPath: indexPath) {
            return expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "AddExpenseSourceCollectionViewCell",
                                                                   for: indexPath)
        }
        
        guard let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath)
             else {
                
                return UICollectionViewCell()
        }
        
        if expenseSourceViewModel.isGoal,
            let cell = expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "GoalExpenseSourceCollectionViewCell",
                                                                       for: indexPath) as? GoalExpenseSourceCollectionViewCell {
            
            cell.viewModel = expenseSourceViewModel
            return cell
        }
        
        if !expenseSourceViewModel.isGoal,
            let cell = expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseSourceCollectionViewCell",
                                                                         for: indexPath) as? ExpenseSourceCollectionViewCell {
                
            cell.viewModel = expenseSourceViewModel
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    private func moveExpenseSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.moveExpenseSource(from: sourceIndexPath,
                                        to: destinationIndexPath)
            }.done {
                self.update(self.expenseSourcesCollectionView)
            }
            .catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка кошельков", theme: .error)
            }.finally {
                self.set(self.expenseSourcesActivityIndicator, hidden: true)
        }
    }
    
    private func removeExpenseSource(by id: Int) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.removeExpenseSource(by: id)
        }.done {
            self.update(self.expenseSourcesCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления кошелька", theme: .error)
        }.finally {
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
        }
    }
}

extension MainViewController : ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        loadExpenseCategories(by: basketType)
        loadBaskets()
        guard case basketType = BasketType.joy else {
            showDependentIncomeSourceMessage(basketType: basketType, name: name)
            didCreateIncomeSource()
            return
        }
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        loadExpenseCategories(by: basketType)
        guard case basketType = BasketType.joy else {
            didUpdateIncomeSource()
            return
        }
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        loadExpenseCategories(by: basketType)
        loadBaskets()
        guard case basketType = BasketType.joy else {
            didRemoveIncomeSource()
            return
        }
    }
    
    private func showDependentIncomeSourceMessage(basketType: BasketType, name: String) {
        if let dependentIncomeSourceCreationMessageViewController = router.viewController(.DependentIncomeSourceCreationMessageViewController) as? DependentIncomeSourceCreationMessageViewController,
            let point = uiPoint(of: basketType),
            !UIFlowManager.reached(point: point) {
            
            dependentIncomeSourceCreationMessageViewController.basketType = basketType
            dependentIncomeSourceCreationMessageViewController.name = name
            
            dependentIncomeSourceCreationMessageViewController.modalPresentationStyle = .overCurrentContext
            dependentIncomeSourceCreationMessageViewController.modalTransitionStyle = .crossDissolve
            present(dependentIncomeSourceCreationMessageViewController, animated: true, completion: nil)
            
        }
        
    }
    
    private func uiPoint(of basketType: BasketType) -> UIFlowPoint? {
        switch basketType {
        case .risk:
            return .dependentRiskIncomeSourceMessage
        case .safe:
            return .dependentSafeIncomeSourceMessage
        default:
            return nil
        }
    }
    
    private func expenseCategoriesActivityIndicator(by basketType: BasketType) -> UIView {
        switch basketType {
        case .joy:
            return joyExpenseCategoriesActivityIndicator
        case .risk:
            return riskExpenseCategoriesActivityIndicator
        case .safe:
            return safeExpenseCategoriesActivityIndicator
        }
    }
    
    private func expenseCategoriesCollectionView(by basketType: BasketType) -> UICollectionView {
        switch basketType {
        case .joy:
            return joyExpenseCategoriesCollectionView
        case .risk:
            return riskExpenseCategoriesCollectionView
        case .safe:
            return safeExpenseCategoriesCollectionView
        }
    }
    
    private func expenseCategoriesPageControl(by basketType: BasketType) -> UIPageControl {
        switch basketType {
        case .joy:
            return joyExpenseCategoriesPageControl
        case .risk:
            return riskExpenseCategoriesPageControl
        case .safe:
            return safeExpenseCategoriesPageControl
        }
    }
    
    private func loadExpenseCategories(by basketType: BasketType, scrollToEndWhenUpdated: Bool = false) {
        set(expenseCategoriesActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.loadExpenseCategories(by: basketType)
        }.done {
            self.update(self.expenseCategoriesCollectionView(by: basketType),
                        scrollToEnd: scrollToEndWhenUpdated)
            self.updateExpenseCategoriesPageControl(by: basketType)            
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки категорий трат", theme: .error)
        }.finally {
            self.set(self.expenseCategoriesActivityIndicator(by: basketType), hidden: true)
        }
    }
    
    private func updateExpenseCategoriesPageControl(by basketType: BasketType) {
        let collectionView = expenseCategoriesCollectionView(by: basketType)
        let pageControl = expenseCategoriesPageControl(by: basketType)
        
        guard let layout = collectionView.collectionViewLayout as? PagedCollectionViewLayout else {
            pageControl.isHidden = true
            return
        }
        
        let pagesCount = layout.numberOfPages
        pageControl.numberOfPages = pagesCount
        pageControl.isHidden = pagesCount <= 1
    }
    
    private func didSelectExpenseCategory(at indexPath: IndexPath, basketType: BasketType) {
        guard viewModel.isAddCategoryItem(indexPath: indexPath, basketType: basketType) else { return }
        
        showNewExpenseCategoryScreen(basketType: basketType)
    }
    
    private func showNewExpenseCategoryScreen(basketType: BasketType) {
        showEditScreen(expenseCategory: nil, basketType: basketType)
    }
    
    private func showEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType) {
        if  let expenseCategoryEditNavigationController = router.viewController(.ExpenseCategoryEditNavigationController) as? UINavigationController,
            let expenseCategoryEditViewController = expenseCategoryEditNavigationController.topViewController as? ExpenseCategoryEditInputProtocol {
            
            expenseCategoryEditViewController.set(delegate: self)
            expenseCategoryEditViewController.set(basketType: basketType)
            
            if let expenseCategory = expenseCategory {
                expenseCategoryEditViewController.set(expenseCategory: expenseCategory)
            }
            
            present(expenseCategoryEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func expenseCategoryCollectionViewCell(forItemAt indexPath: IndexPath, basketType: BasketType) -> UICollectionViewCell {
        
        let collectionView = expenseCategoriesCollectionView(by: basketType)
        
        if viewModel.isAddCategoryItem(indexPath: indexPath, basketType: basketType) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddExpenseCategoryCollectionViewCell",
                                                      for: indexPath)
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseCategoryCollectionViewCell",
                                                            for: indexPath) as? ExpenseCategoryCollectionViewCell,
            let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath,
                                                                              basketType: basketType) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = expenseCategoryViewModel
        return cell
    }
    
    private func moveExpenseCategory(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, basketType: BasketType) {
        
        set(expenseCategoriesActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.moveExpenseCategory(from: sourceIndexPath,
                                          to: destinationIndexPath,
                                          basketType: basketType)
            }.done {
                self.update(self.expenseCategoriesCollectionView(by: basketType))
            }
            .catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка категорий трат", theme: .error)
            }.finally {
                self.set(self.expenseCategoriesActivityIndicator(by: basketType), hidden: true)
        }
    }
    
    private func removeExpenseCategory(by id: Int, basketType: BasketType) {
        set(expenseCategoriesActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.removeExpenseCategory(by: id, basketType: basketType)
        }.done {
            self.update(self.expenseCategoriesCollectionView(by: basketType))
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления категории трат", theme: .error)
        }.finally {
            self.set(self.expenseCategoriesActivityIndicator(by: basketType), hidden: true)
        }
    }
}

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case incomeSourcesCollectionView:           return 1
        case expenseSourcesCollectionView:          return 1
        case joyExpenseCategoriesCollectionView:    return 1
        case riskExpenseCategoriesCollectionView:   return 1
        case safeExpenseCategoriesCollectionView:   return 1
        default:                                    return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case incomeSourcesCollectionView:           return viewModel.numberOfIncomeSources
        case expenseSourcesCollectionView:          return viewModel.numberOfExpenseSources
        case joyExpenseCategoriesCollectionView:    return viewModel.numberOfJoyExpenseCategories
        case riskExpenseCategoriesCollectionView:   return viewModel.numberOfRiskExpenseCategories
        case safeExpenseCategoriesCollectionView:   return viewModel.numberOfSafeExpenseCategories
        default:                                    return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        func collectionViewCell() -> UICollectionViewCell {
            switch collectionView {
            case incomeSourcesCollectionView:           return incomeSourceCollectionViewCell(forItemAt: indexPath)
            case expenseSourcesCollectionView:          return expenseSourceCollectionViewCell(forItemAt: indexPath)
            case joyExpenseCategoriesCollectionView:    return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .joy)
            case riskExpenseCategoriesCollectionView:   return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .risk)
            case safeExpenseCategoriesCollectionView:   return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .safe)
            default:                                    return UICollectionViewCell()
            }
        }
        
        let cell = collectionViewCell()
        
        guard let editableCell = cell as? EditableCell else { return cell }
        
        if isEditing {
            if indexPath != movingIndexPath || collectionView != movingCollectionView {
                editableCell.set(editing: true)
            }
        } else {
            editableCell.set(editing: false)
        }
        
        editableCell.delegate = self
        
        guard collectionView == movingCollectionView else { return cell }
        
        if indexPath == movingIndexPath {
            cell.alpha = 0.99
            cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } else {
            cell.alpha = 1.0
            cell.transform = CGAffineTransform.identity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        switch collectionView {
        case incomeSourcesCollectionView:           moveIncomeSource(from: sourceIndexPath,
                                                                     to: destinationIndexPath)
        case expenseSourcesCollectionView:          moveExpenseSource(from: sourceIndexPath,
                                                                      to: destinationIndexPath)
        case joyExpenseCategoriesCollectionView:    moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .joy)
        case riskExpenseCategoriesCollectionView:   moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .risk)
        case safeExpenseCategoriesCollectionView:   moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .safe)
        default: return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditing else { return }
        
        switch collectionView {
        case incomeSourcesCollectionView:           didSelectIncomeSource(at: indexPath)
        case expenseSourcesCollectionView:          didSelectExpenseSource(at: indexPath)
        case joyExpenseCategoriesCollectionView:    didSelectExpenseCategory(at: indexPath, basketType: .joy)
        case riskExpenseCategoriesCollectionView:   didSelectExpenseCategory(at: indexPath, basketType: .risk)
        case safeExpenseCategoriesCollectionView:   didSelectExpenseCategory(at: indexPath, basketType: .safe)
        default: return
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl(for: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageControl(for: scrollView)
    }
    
    private func updatePageControl(for scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        switch collectionView {
        case joyExpenseCategoriesCollectionView:    updatePageControl(basketType: .joy)
        case riskExpenseCategoriesCollectionView:   updatePageControl(basketType: .risk)
        case safeExpenseCategoriesCollectionView:   updatePageControl(basketType: .safe)
        default: return
        }
    }
    
    private func updatePageControl(basketType: BasketType) {
        let collectionView = expenseCategoriesCollectionView(by: basketType)
        expenseCategoriesPageControl(by: basketType).currentPage = Int(collectionView.contentOffset.x) / Int(collectionView.frame.width)
    }    
}

extension MainViewController : EditableCellDelegate {
    func didTapDeleteButton(cell: EditableCell) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        
        if let incomeSourceId = (cell as? IncomeSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = "Удалить источник доходов?"
            removeAction = { _ in
                self.removeIncomeSource(by: incomeSourceId)
            }
        }
        if let expenseSourceId = (cell as? ExpenseSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = "Удалить кошелек?"
            removeAction = { _ in
                self.removeExpenseSource(by: expenseSourceId)
            }
        }
        if let expenseCategoryViewModel = (cell as? ExpenseCategoryCollectionViewCell)?.viewModel {
            alertTitle = "Удалить категорию трат?"
            removeAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryViewModel.id, basketType: expenseCategoryViewModel.expenseCategory.basketType)
            }
        }
        
        let alertController = UIAlertController(title: alertTitle,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: removeAction)
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
    
    func didTapEditButton(cell: EditableCell) {
        if let incomeSource = (cell as? IncomeSourceCollectionViewCell)?.viewModel?.incomeSource {
            showEditScreen(incomeSource: incomeSource)
        }
        if let expenseSource = (cell as? ExpenseSourceCollectionViewCell)?.viewModel?.expenseSource {
            showEditScreen(expenseSource: expenseSource)
        }
        if let expenseCategoryViewModel = (cell as? ExpenseCategoryCollectionViewCell)?.viewModel {
            showEditScreen(expenseCategory: expenseCategoryViewModel.expenseCategory,
                           basketType: expenseCategoryViewModel.expenseCategory.basketType)
        }
    }    
}

extension MainViewController {
    private func setupUI() {
        setupIncomeSourcesCollectionView()
        setupExpenseSourcesCollectionView()
        setupExpenseCategoriesCollectionView()
        setupNavigationBar()
        setupMainMenu()
        setupLoaders()
        setupGestureRecognizers()
        setupNotifications()
    }
    
    private func setupIncomeSourcesCollectionView() {
        incomeSourcesCollectionView.delegate = self
        incomeSourcesCollectionView.dataSource = self
    }
    
    private func setupExpenseSourcesCollectionView() {
        expenseSourcesCollectionView.delegate = self
        expenseSourcesCollectionView.dataSource = self
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
        gestureRecognizer.minimumPressDuration = 1.0
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finantialDataInvalidated), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    @objc private func appMovedToForeground() {
        setVisibleCells(editing: isEditing)
    }
    
    @objc private func finantialDataInvalidated() {
        loadData()
    }
    
    private func layoutUI() {
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
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.init(red: 48 / 255.0,
                                                                                green: 53 / 255.0,
                                                                                blue: 79 / 255.0,
                                                                                alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setupMainMenu() {
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
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
}

extension MainViewController {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func didRecognizeRearrangeGesture(gesture: UILongPressGestureRecognizer) {
        movingCollectionView = gesture.view as? UICollectionView
        
        guard let movingCollectionView = movingCollectionView else { return }
        
        let location = gesture.location(in: movingCollectionView)
        
        
        switch gesture.state {
        case .began:
            if !isEditing {
                setEditing(true, animated: true)
                transactionDraggingElement.isHidden = true
                return
            }
            movingIndexPath = movingCollectionView.indexPathForItem(at: location)
            
            guard let indexPath = movingIndexPath else { return }
            
            let cell = movingCollectionView.cellForItem(at: indexPath)
            
            
            
            movingCollectionView.beginInteractiveMovementForItem(at: indexPath)
            
            
            
            // This is the class variable I mentioned above
            if let cell = cell {
                offsetForCollectionViewCellBeingMoved = offsetOfTouchFrom(recognizer: gesture, inCell: cell)
            }
            
            // This is the vanilla location of the touch that alone would make the cell's center snap to your touch location
            var location = gesture.location(in: movingCollectionView)
            
            /* These two lines add the offset calculated a couple lines up to
             the normal location to make it so you can drag from any part of the
             cell and have it stay where your finger is. */
            
            location.x += offsetForCollectionViewCellBeingMoved.x
            location.y += offsetForCollectionViewCellBeingMoved.y
            
            movingCollectionView.updateInteractiveMovementTargetPosition(location)
            
            (cell as? EditableCell)?.set(editing: false)
            animatePickingUp(cell: cell)
        case .changed:
            
            var location = gesture.location(in: movingCollectionView)
            
            location.x += offsetForCollectionViewCellBeingMoved.x
            location.y += offsetForCollectionViewCellBeingMoved.y
            
            movingCollectionView.updateInteractiveMovementTargetPosition(location)
        default:
            gesture.state == .ended
                ? movingCollectionView.endInteractiveMovement()
                : movingCollectionView.cancelInteractiveMovement()
            
            guard let indexPath = movingIndexPath else { return }
            
            let cell = movingCollectionView.cellForItem(at: indexPath)
            
            animatePuttingDown(cell: cell)
            movingIndexPath = nil
        }
        
    }
    
    func offsetOfTouchFrom(recognizer: UIGestureRecognizer, inCell cell: UICollectionViewCell) -> CGPoint {
        
        let locationOfTouchInCell = recognizer.location(in: cell)
        
        let cellCenterX = cell.frame.width / 2
        let cellCenterY = cell.frame.height / 2
        
        let cellCenter = CGPoint(x: cellCenterX, y: cellCenterY)
        
        var offSetPoint = CGPoint.zero
        
        offSetPoint.y = cellCenter.y - locationOfTouchInCell.y
        offSetPoint.x = cellCenter.x - locationOfTouchInCell.x
        
        return offSetPoint
        
    }
    
    func animatePickingUp(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.alpha = 0.99
            cell?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { finished in
            
        })
    }
    
    func animatePuttingDown(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.alpha = 1.0
            cell?.transform = CGAffineTransform.identity
        }, completion: { finished in
            (cell as? EditableCell)?.set(editing: true)
        })
    }
    
    func setVisibleCells(editing: Bool) {
        let cells = incomeSourcesCollectionView.visibleCells + expenseSourcesCollectionView.visibleCells + joyExpenseCategoriesCollectionView.visibleCells + riskExpenseCategoriesCollectionView.visibleCells + safeExpenseCategoriesCollectionView.visibleCells
        
        for cell in cells {
            (cell as? EditableCell)?.set(editing: editing)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        guard editing != isEditing else { return }
        
        super.setEditing(editing, animated: animated)
        
        viewModel?.set(editing: editing)
        
        updateCollectionViews()
        
        setVisibleCells(editing: editing)
        
        UIView.animate(withDuration: 0.1) {
            self.editDoneButton.alpha = editing ? 1.0 : 0.0
            self.editDoneButtonHeightConstraint.constant = editing ? 30 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCollectionViews() {
        update(incomeSourcesCollectionView)
        update(expenseSourcesCollectionView)
        update(joyExpenseCategoriesCollectionView)
        update(riskExpenseCategoriesCollectionView)
        update(safeExpenseCategoriesCollectionView)
    }
}

extension MainViewController {
    private func setupTransactionGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeTransactionGesture(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.15
        gestureRecognizer.delegate = self
    }
    
    private func switchOffScrolling(for collectionView: UICollectionView) {
        collectionView.panGestureRecognizer.isEnabled = false
        collectionView.panGestureRecognizer.isEnabled = true
    }
    
    @objc func didRecognizeTransactionGesture(gesture: UIPanGestureRecognizer) {
        
        guard !isEditing else { return }
        
        switch gesture.state {
        case .began:
            var locationInView = gesture.location(in: self.view)
            
            let collectionViews: [UICollectionView] = [incomeSourcesCollectionView,
                                                       expenseSourcesCollectionView]
            
            transactionStartedCollectionView = collectionViews.first(where: { collectionView in
                let pointInside = self.view.convert(locationInView, to: collectionView)
                return collectionView.bounds.contains(pointInside)
            })
            
            guard let transactionStartedCollectionView = transactionStartedCollectionView else { return }
            
            switchOffScrolling(for: transactionStartedCollectionView)
            
            var locationInCollectionView = gesture.location(in: transactionStartedCollectionView)
            
            guard let indexPath = transactionStartedCollectionView.indexPathForItem(at: locationInCollectionView) else {

                self.transactionStartedCollectionView = nil
                return
            }

            transactionStartedCell = transactionStartedCollectionView.cellForItem(at: indexPath)
            transactionDraggingElement.isHidden = false
            transactionDraggingElement.center = locationInView.applying(CGAffineTransform(translationX: 0, y: -30))
            animateTransactionStarted(cell: transactionStartedCell)
            
        case .changed:
            
            guard let transactionStartedCollectionView = transactionStartedCollectionView else {
                animateTransactionFinished(cell: transactionStartedCell)
                animateTransactionFinished(cell: dropCandidateCell)
                return
            }
            
            switchOffScrolling(for: transactionStartedCollectionView)
            
            var locationInView = gesture.location(in: self.view)

            transactionDraggingElement.center = locationInView.applying(CGAffineTransform(translationX: 0, y: -30))
            
            func intersectedCell() -> UICollectionViewCell? {
                let collectionViews: [UICollectionView] = [expenseSourcesCollectionView,
                                                           joyExpenseCategoriesCollectionView,
                                                           riskExpenseCategoriesCollectionView,
                                                           safeExpenseCategoriesCollectionView]
                
                guard let intersectedCollectionView = collectionViews.first(where: { collectionView in
                    let pointInside = self.view.convert(locationInView, to: collectionView)
                    
                    return collectionView.bounds.contains(pointInside)
                }) else { return nil }
                
                
                let location = gesture.location(in: intersectedCollectionView).applying(CGAffineTransform(translationX: 0, y: -30))
                
                guard let indexPath = intersectedCollectionView.indexPathForItem(at: location) else { return nil }
                
                return intersectedCollectionView.cellForItem(at: indexPath)
            }
            
            let cell = intersectedCell()
            
            func checkIfDropCandidate() -> Bool {
                guard cell != dropCandidateCell else { return false }
                return true
            }
            
            guard checkIfDropCandidate() else { return }

            animateTransactionFinished(cell: dropCandidateCell)
            dropCandidateCell = cell
            animateTransactionDropCandidate(cell: cell)
            
        default:
            guard let transactionStartedCell = transactionStartedCell else {
                transactionDraggingElement.isHidden = true
                return
            }
            if let dropCandidateCell = dropCandidateCell {
                animateTransactionCompleted(from: transactionStartedCell, to: dropCandidateCell)
            } else {
                animateTransactionCancelled(from: transactionStartedCell)
            }
            self.dropCandidateCell = nil
            self.transactionStartedCell = nil
        }
    }
    
    private func animateTransactionStarted(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    private func animateTransactionDropCandidate(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    private func animateTransactionFinished(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func animateTransactionCompleted(from fromCell: UICollectionViewCell, to toCell: UICollectionViewCell) {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                self.transactionDraggingElement.center = toCell.convert(toCell.contentView.center, to: self.view)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                self.transactionDraggingElement.transform = CGAffineTransform(scaleX: 0, y: 0)
                fromCell.transform = CGAffineTransform.identity
                toCell.transform = CGAffineTransform.identity
            })
        }, completion:{ _ in
            self.transactionDraggingElement.isHidden = true
            self.transactionDraggingElement.transform = CGAffineTransform.identity
        })
    }
    
    private func animateTransactionCancelled(from cell: UICollectionViewCell) {
        UIView.animateKeyframes(withDuration: 0.6, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.transactionDraggingElement.center = cell.convert(cell.contentView.center, to: self.view)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.transactionDraggingElement.transform = CGAffineTransform(scaleX: 0, y: 0)
                cell.transform = CGAffineTransform.identity
            })
        }, completion:{ _ in
            self.transactionDraggingElement.isHidden = true
            self.transactionDraggingElement.transform = CGAffineTransform.identity
        })
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

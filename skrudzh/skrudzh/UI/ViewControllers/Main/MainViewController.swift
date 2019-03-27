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
    var soundsManager: SoundsManagerProtocol!
    
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
    
    private var budgetView: BudgetView!
    
    private var movingIndexPath: IndexPath? = nil
    private var movingCollectionView: UICollectionView? = nil
    private var offsetForCollectionViewCellBeingMoved: CGPoint = .zero
    
    private var transactionStartedLocation: CGPoint? = nil
    private var transactionStartedCollectionView: UICollectionView? = nil {
        didSet {
            if transactionStartedCollectionView != oldValue {
                transactionStartedIndexPath = nil
                transactionStartedLocation = nil
            }
        }
    }
    
    private var transactionStartedIndexPath: IndexPath? = nil {
        didSet {
            if transactionStartedIndexPath != oldValue {
                transactionStartedCell = nil
            }
        }
    }
    private var transactionStartedCell: UICollectionViewCell? = nil {
        didSet {
            if transactionStartedCell != oldValue {
                animateTransactionFinished(cell: oldValue)
                animateTransactionStarted(cell: transactionStartedCell)
            }
        }
    }
    
    
    
    private var dropCandidateCollectionView: UICollectionView? = nil {
        didSet {
            if dropCandidateCollectionView != oldValue {
                initializeWaitingAtTheEdge()
                dropCandidateIndexPath = nil
            }
        }
    }
    private var dropCandidateIndexPath: IndexPath? = nil {
        didSet {
            if dropCandidateIndexPath != oldValue {
                dropCandidateCell = nil
            }
        }
    }
    private var dropCandidateCell: UICollectionViewCell? = nil {
        didSet {
            if dropCandidateCell != oldValue {
                animateTransactionFinished(cell: oldValue)
                animateTransactionDropCandidate(cell: dropCandidateCell)
            }
        }
    }
    
    private var waitingAtTheEdgeTimer: Timer? = nil
    
    private var waitingEdge: UIRectEdge? = nil {
        didSet {
            if waitingEdge != oldValue {
                initializeWaitingAtTheEdge()
            } else if waitingEdge == nil  {
                waitingAtTheEdgeTimer?.invalidate()
                waitingAtTheEdgeTimer = nil
            }
        }
    }
    
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
        loadBudget()
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

extension MainViewController {
    private func loadBudget() {
        firstly {
            viewModel.loadBudget()
        }.done {
            self.updateBudgetUI()
        }
        .catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки баланса", theme: .error)
        }.finally {
                
        }
    }
    
    private func updateBudgetUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.budgetView.balanceLabel.text = self.viewModel.balance
                            self.budgetView.monthlySpentLabel.text = self.viewModel.monthlySpent
                            self.budgetView.monthlyPlannedLabel.text = self.viewModel.monthlyPlanned
        })
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
        loadBudget()
        loadExpenseSources()
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
    
    private func removeIncomeSource(by id: Int, deleteTransactions: Bool) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.removeIncomeSource(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveIncomeSource()
        }
        .catch { _ in
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления источника дохода", theme: .error)
        }
    }
}

extension MainViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        loadExpenseSources()
        loadBudget()
    }
    
    func didUpdateExpenseSource() {
        loadExpenseSources()
        loadBudget()
    }
    
    func didRemoveExpenseSource() {
        loadExpenseSources()
        loadBudget()
        loadBaskets()
        loadIncomeSources()
        loadExpenseCategories(by: .joy)
        loadExpenseCategories(by: .safe)
        loadExpenseCategories(by: .risk)
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
    
    private func removeExpenseSource(by id: Int, deleteTransactions: Bool) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.removeExpenseSource(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveExpenseSource()
        }
        .catch { _ in
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления кошелька", theme: .error)
        }
    }
}

extension MainViewController : ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        loadExpenseCategories(by: basketType)
        loadBaskets()
        loadBudget()
        guard case basketType = BasketType.joy else {
            showDependentIncomeSourceMessage(basketType: basketType, name: name)
            didCreateIncomeSource()
            return
        }
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        loadExpenseCategories(by: basketType)
        loadBudget()
        guard case basketType = BasketType.joy else {
            didUpdateIncomeSource()
            return
        }
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        loadExpenseCategories(by: basketType)
        loadBaskets()
        loadBudget()
        loadExpenseSources()
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
    
    private func removeExpenseCategory(by id: Int, basketType: BasketType, deleteTransactions: Bool) {
        set(expenseCategoriesActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.removeExpenseCategory(by: id, basketType: basketType, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveExpenseCategory(with: basketType)
        }
        .catch { _ in
            self.set(self.expenseCategoriesActivityIndicator(by: basketType), hidden: true)
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления категории трат", theme: .error)
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
        
        if collectionView == movingCollectionView {
            if indexPath == movingIndexPath {
                cell.alpha = 0.99
                cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                cell.alpha = 1.0
                cell.transform = CGAffineTransform.identity
            }
        }
        
        if collectionView == transactionStartedCollectionView {
            if indexPath == transactionStartedIndexPath {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            else {
                cell.transform = CGAffineTransform.identity
            }
        }
        
        if collectionView == dropCandidateCollectionView {
            if indexPath == dropCandidateIndexPath {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            else {
                cell.transform = CGAffineTransform.identity
            }
        }
        
        if collectionView == transactionStartedCollectionView && collectionView == dropCandidateCollectionView {
            if indexPath == transactionStartedIndexPath {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            else if indexPath == dropCandidateIndexPath {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            else {
                cell.transform = CGAffineTransform.identity
            }
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
        var removeWithTransactionsAction: ((UIAlertAction) -> Void)? = nil
        
        if let incomeSourceId = (cell as? IncomeSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = "Удалить источник доходов?"
            removeAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: true)
            }
        }
        if let expenseSourceId = (cell as? ExpenseSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = "Удалить кошелек?"
            removeAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: true)
            }
        }
        if let expenseCategoryViewModel = (cell as? ExpenseCategoryCollectionViewCell)?.viewModel {
            alertTitle = "Удалить категорию трат?"
            removeAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryViewModel.id,
                                           basketType: expenseCategoryViewModel.expenseCategory.basketType,
                                           deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryViewModel.id,
                                           basketType: expenseCategoryViewModel.expenseCategory.basketType,
                                           deleteTransactions: true)
            }
        }
        
        let alertController = UIAlertController(title: alertTitle,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: removeAction)
        
        alertController.addAction(title: "Удалить вместе с транзакциями",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: removeWithTransactionsAction)
        
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
        gestureRecognizer.minimumPressDuration = 0.95
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
        self.budgetView = BudgetView(frame: CGRect.zero)
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
                transactionStartedCollectionView = nil
                dropCandidateCollectionView = nil
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

typealias CollectionViewIntersection = (collectionView: UICollectionView, indexPath: IndexPath?, cell: UICollectionViewCell?)?

extension MainViewController {
    private func setupTransactionGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didRecognizeTransactionGesture(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.0525
        gestureRecognizer.delegate = self
    }
    
    private func switchOffScrolling(for collectionView: UICollectionView?) {
        guard let collectionView = collectionView else { return }
        collectionView.panGestureRecognizer.isEnabled = false
        collectionView.panGestureRecognizer.isEnabled = true
    }
    
    private func detectCollectionViewIntersection(at location: CGPoint,
                                                  in view: UIView,
                                                  collectionViewsPool: [UICollectionView],
                                                  transformation: CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)) -> CollectionViewIntersection {
        
        guard let intersectedCollectionView = collectionViewsPool.first(where: { collectionView in
            let pointInside = view.convert(location, to: collectionView)
            return collectionView.bounds.contains(pointInside)
        }) else {
            return nil
        }
        
        let locationInCollectionView = view.convert(location, to: intersectedCollectionView).applying(transformation)
        
        guard let indexPath = intersectedCollectionView.indexPathForItem(at: locationInCollectionView) else {
            return (collectionView: intersectedCollectionView, indexPath: nil, cell: nil)
        }
        
        let cell = intersectedCollectionView.cellForItem(at: indexPath)
        
        return (collectionView: intersectedCollectionView, indexPath: indexPath, cell: cell)
    }
    
    private func initializeWaitingAtTheEdge() {
        waitingAtTheEdgeTimer?.invalidate()
        if dropCandidateCollectionView != nil && waitingEdge != nil && !isEditing {
            waitingAtTheEdgeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeWaitingPage), userInfo: nil, repeats: false)
        } else {
            waitingAtTheEdgeTimer = nil
        }
    }
    
    @objc private func changeWaitingPage() {
        guard   !isEditing,
                let edge = waitingEdge,
                let dropCandidateCollectionView = dropCandidateCollectionView else {
                    
                    initializeWaitingAtTheEdge()
                    return
                    
        }
        
        let offsetDiff = edge == .right ? self.view.frame.size.width : -self.view.frame.size.width
        var offset = dropCandidateCollectionView.contentOffset.x + offsetDiff
        if offset < 0 {
           offset = 0
        }
        if offset > (dropCandidateCollectionView.contentSize.width - offsetDiff) {
            offset = dropCandidateCollectionView.contentSize.width - offsetDiff
        }
        dropCandidateCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        initializeWaitingAtTheEdge()
    }
    
    private func getWaitingEdge(at location: CGPoint, in view: UIView) -> UIRectEdge? {
        if location.x < 50 {
            return .left
        }
        if location.x > (view.frame.size.width - 50) {
            return .right
        }
        return nil
    }
    
    private func updateWaitingEdge(at location: CGPoint, in view: UIView) {
        waitingEdge = getWaitingEdge(at: location, in: view)
    }
    
    private func canStartTransaction(collectionView: UICollectionView?, indexPath: IndexPath?) -> Bool {
        guard   let collectionView = collectionView,
                let indexPath = indexPath,
                let transactionStartable = transactionStartable(collectionView: collectionView, indexPath: indexPath) else { return false }
        return transactionStartable.canStartTransaction
    }
    
    private func transactionStartable(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionStartable? {
        switch collectionView {
        case incomeSourcesCollectionView:
            return viewModel.incomeSourceViewModel(at: indexPath)
        case expenseSourcesCollectionView:
            return viewModel.expenseSourceViewModel(at: indexPath)
        default:
            return nil
        }
    }
    
    private func canCompleteTransaction(transactionStartedCollectionView: UICollectionView?,
                                        transactionStartedIndexPath: IndexPath?,
                                        completionCandidateCollectionView: UICollectionView?,
                                        completionCandidateIndexPath: IndexPath?) -> Bool {
        guard   let transactionStartedCollectionView = transactionStartedCollectionView,
                let transactionStartedIndexPath = transactionStartedIndexPath,
                let completionCandidateCollectionView = completionCandidateCollectionView,
                let completionCandidateIndexPath = completionCandidateIndexPath else { return false }
        
        guard   let transactionStartable = transactionStartable(collectionView: transactionStartedCollectionView, indexPath: transactionStartedIndexPath),
                let transactionCompletable = transactionCompletable(collectionView: completionCandidateCollectionView, indexPath: completionCandidateIndexPath) else { return false }
        
        return transactionCompletable.canComplete(startable: transactionStartable)
    }
    
    private func transactionCompletable(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionCompletable? {
        switch collectionView {
        case expenseSourcesCollectionView:
            return viewModel.expenseSourceViewModel(at: indexPath)
        case joyExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath, basketType: .joy)
        case riskExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath, basketType: .risk)
        case safeExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath, basketType: .safe)
        default:
            return nil
        }
    }
    
    func updateDraggingElement(location: CGPoint, transform: CGAffineTransform) {
        guard let transactionStartedLocation = transactionStartedLocation else {
            transactionDraggingElement.isHidden = true
            return
        }
        if transactionDraggingElement.isHidden {
            transactionDraggingElement.isHidden = location.distance(from: transactionStartedLocation) < 3
        }
        transactionDraggingElement.center = location.applying(transform)
    }
    
    @objc func didRecognizeTransactionGesture(gesture: UILongPressGestureRecognizer) {
        
        guard !isEditing else { return }
        
        let locationInView = gesture.location(in: self.view)
        let verticalTranslationTransformation = CGAffineTransform(translationX: 0, y: -30)
        
        switch gesture.state {
        case .began:
            
            let collectionViews: [UICollectionView] = [incomeSourcesCollectionView,
                                                       expenseSourcesCollectionView]
            
            let intersections = detectCollectionViewIntersection(at: locationInView,
                                                                 in: self.view,
                                                                 collectionViewsPool: collectionViews)
            
            transactionStartedCollectionView = intersections?.collectionView
            transactionStartedIndexPath = intersections?.indexPath
            
            guard   let cell = intersections?.cell,
                    canStartTransaction(collectionView: transactionStartedCollectionView,
                                        indexPath: transactionStartedIndexPath) else {
                        
                
                self.transactionStartedCollectionView = nil
                transactionDraggingElement.isHidden = true
                return
            }
            
            transactionStartedLocation = locationInView
            transactionStartedCell = cell
            updateDraggingElement(location: locationInView, transform: verticalTranslationTransformation)
            switchOffScrolling(for: transactionStartedCollectionView)
            
        case .changed:
            
            guard   let transactionStartedCollectionView = transactionStartedCollectionView,
                    let transactionStartedIndexPath = transactionStartedIndexPath else {
                animateTransactionFinished(cell: self.transactionStartedCell)
                animateTransactionFinished(cell: dropCandidateCell)
                return
            }
            
            switchOffScrolling(for: transactionStartedCollectionView)
            
            updateDraggingElement(location: locationInView, transform: verticalTranslationTransformation)
            
            
            let collectionViews: [UICollectionView] = [expenseSourcesCollectionView,
                                                       joyExpenseCategoriesCollectionView,
                                                       riskExpenseCategoriesCollectionView,
                                                       safeExpenseCategoriesCollectionView]
            
            let intersections = detectCollectionViewIntersection(at: locationInView,
                                                                 in: self.view,
                                                                 collectionViewsPool: collectionViews,
                                                                 transformation: verticalTranslationTransformation)
            
            
            
            
            dropCandidateCollectionView = intersections?.collectionView
            
            updateWaitingEdge(at: locationInView, in: self.view)
            
            if dropCandidateCollectionView == transactionStartedCollectionView && intersections?.indexPath == transactionStartedIndexPath {
                dropCandidateIndexPath = nil
                return
            }
            
            let canComplete = canCompleteTransaction(transactionStartedCollectionView: transactionStartedCollectionView,
                                                     transactionStartedIndexPath: transactionStartedIndexPath,
                                                     completionCandidateCollectionView: dropCandidateCollectionView,
                                                     completionCandidateIndexPath: intersections?.indexPath)
            
            dropCandidateIndexPath = canComplete ? intersections?.indexPath : nil
            dropCandidateCell = canComplete ? intersections?.cell : nil
            
        default:
            guard   let transactionStartedCollectionView = transactionStartedCollectionView,
                    let transactionStartedIndexPath = transactionStartedIndexPath else {
                transactionDraggingElement.isHidden = true
                return
            }
            
            let transactionStartedCell = transactionStartedCollectionView.cellForItem(at: transactionStartedIndexPath)
            
            if  let dropCandidateCollectionView = dropCandidateCollectionView,
                let dropCandidateIndexPath = dropCandidateIndexPath,
                let dropCandidateCell = dropCandidateCollectionView.cellForItem(at: dropCandidateIndexPath),
                let transactionStartable = transactionStartable(collectionView: transactionStartedCollectionView, indexPath: transactionStartedIndexPath),
                let transactionCompletable = transactionCompletable(collectionView: dropCandidateCollectionView, indexPath: dropCandidateIndexPath) {
                
                animateTransactionCompleted(from: transactionStartedCell, to: dropCandidateCell, completed: {
                    self.showTransactionEditScreen(transactionStartable: transactionStartable, transactionCompletable: transactionCompletable)
                })
                
            } else {
                animateTransactionCancelled(from: transactionStartedCell)
            }
        }
    }
    
    private func showTransactionEditScreen(transactionStartable: TransactionStartable, transactionCompletable: TransactionCompletable) {
        soundsManager.playTransactionStartedSound()
        switch (transactionStartable, transactionCompletable) {
        case (let startable as IncomeSourceViewModel, let completable as ExpenseSourceViewModel):
            showIncomeEditScreen(incomeSourceStartable: startable, expenseSourceCompletable: completable)
        case (let startable as ExpenseSourceViewModel, let completable as ExpenseSourceViewModel):
            showFundsMoveEditScreen(expenseSourceStartable: startable, expenseSourceCompletable: completable)
        case (let startable as ExpenseSourceViewModel, let completable as ExpenseCategoryViewModel):
            showExpenseEditScreen(expenseSourceStartable: startable, expenseCategoryCompletable: completable)
        default:
            return
        }
    }
    
    private func showIncomeEditScreen(incomeSourceStartable: IncomeSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        if  let incomeEditNavigationController = router.viewController(.IncomeEditNavigationController) as? UINavigationController,
            let incomeEditViewController = incomeEditNavigationController.topViewController as? IncomeEditInputProtocol {
            
            incomeEditViewController.set(delegate: self)
            
            incomeEditViewController.set(startable: incomeSourceStartable, completable: expenseSourceCompletable)
            
            present(incomeEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showFundsMoveEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        if  let fundsMoveEditNavigationController = router.viewController(.FundsMoveEditNavigationController) as? UINavigationController,
            let fundsMoveEditViewController = fundsMoveEditNavigationController.topViewController as? FundsMoveEditInputProtocol {
            
            fundsMoveEditViewController.set(delegate: self)
            
            fundsMoveEditViewController.set(startable: expenseSourceStartable, completable: expenseSourceCompletable)
            
            present(fundsMoveEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showExpenseEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseCategoryCompletable: ExpenseCategoryViewModel) {
        if  let expenseEditNavigationController = router.viewController(.ExpenseEditNavigationController) as? UINavigationController,
            let expenseEditViewController = expenseEditNavigationController.topViewController as? ExpenseEditInputProtocol {
            
            expenseEditViewController.set(delegate: self)
            
            expenseEditViewController.set(startable: expenseSourceStartable, completable: expenseCategoryCompletable)
            
            present(expenseEditNavigationController, animated: true, completion: nil)
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
    
    private func animateTransactionCompleted(from fromCell: UICollectionViewCell?, to toCell: UICollectionViewCell, completed: (() -> Void)? = nil) {
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                self.transactionDraggingElement.center = toCell.convert(toCell.contentView.center, to: self.view)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                self.transactionDraggingElement.transform = CGAffineTransform(scaleX: 0, y: 0)
                fromCell?.transform = CGAffineTransform.identity
                toCell.transform = CGAffineTransform.identity
            })
        }, completion:{ _ in
            self.transactionDraggingElement.isHidden = true
            self.transactionDraggingElement.transform = CGAffineTransform.identity
            self.transactionStartedCollectionView = nil
            self.dropCandidateCollectionView = nil
            completed?()
        })
    }
    
    private func animateTransactionCancelled(from cell: UICollectionViewCell?) {
        UIView.animateKeyframes(withDuration: 0.6, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                if let cell = cell {
                    self.transactionDraggingElement.center = cell.convert(cell.contentView.center, to: self.view)
                }
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.transactionDraggingElement.transform = CGAffineTransform(scaleX: 0, y: 0)
                cell?.transform = CGAffineTransform.identity
            })
        }, completion:{ _ in
            self.transactionDraggingElement.isHidden = true
            self.transactionDraggingElement.transform = CGAffineTransform.identity
            self.transactionStartedCollectionView = nil
            self.dropCandidateCollectionView = nil
        })
    }
}

extension MainViewController: IncomeEditViewControllerDelegate {
    func didCreateIncome() {
        soundsManager.playTransactionCompletedSound()
        updateIncomeDependentData()
    }
    
    func didUpdateIncome() {
        updateIncomeDependentData()
    }
    
    func didRemoveIncome() {
        updateIncomeDependentData()
    }
    
    private func updateIncomeDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
    }
}

extension MainViewController: ExpenseEditViewControllerDelegate {
    func didCreateExpense() {
        soundsManager.playTransactionCompletedSound()
        updateExpenseDependentData()
    }
    
    func didUpdateExpense() {
        updateExpenseDependentData()
    }
    
    func didRemoveExpense() {
        updateExpenseDependentData()
    }
    
    private func updateExpenseDependentData() {
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
        loadExpenseCategories(by: .risk)
        loadExpenseCategories(by: .safe)
    }
}

extension MainViewController: FundsMoveEditViewControllerDelegate {
    func didCreateFundsMove() {
        soundsManager.playTransactionCompletedSound()
        updateFundsMoveDependentData()
    }
    
    func didUpdateFundsMove() {
        updateFundsMoveDependentData()
    }
    
    func didRemoveFundsMove() {
        updateFundsMoveDependentData()
    }
    
    private func updateFundsMoveDependentData() {        
        loadExpenseSources()
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view is UIButton {
            return false
        }
        
        let locationInView = touch.location(in: self.view)
        
        let collectionViews: [UICollectionView] = [incomeSourcesCollectionView,
                                                   expenseSourcesCollectionView,
                                                   joyExpenseCategoriesCollectionView,
                                                   riskExpenseCategoriesCollectionView,
                                                   safeExpenseCategoriesCollectionView]
            
        let intersections = detectCollectionViewIntersection(at: locationInView,
                                                             in: self.view,
                                                             collectionViewsPool: collectionViews)
            
        guard   let collectionView = intersections?.collectionView,
                let indexPath = intersections?.indexPath else {
            return true
        }
        
        
        switch collectionView {
        case incomeSourcesCollectionView:
            return !viewModel.isAddIncomeSourceItem(indexPath: indexPath)
        case expenseSourcesCollectionView:
            return !viewModel.isAddExpenseSourceItem(indexPath: indexPath)
        case joyExpenseCategoriesCollectionView:
            return !viewModel.isAddCategoryItem(indexPath: indexPath, basketType: .joy)
        case riskExpenseCategoriesCollectionView:
            return !viewModel.isAddCategoryItem(indexPath: indexPath, basketType: .risk)
        case safeExpenseCategoriesCollectionView:
            return !viewModel.isAddCategoryItem(indexPath: indexPath, basketType: .safe)
        default:
            return true
        }
    }
}

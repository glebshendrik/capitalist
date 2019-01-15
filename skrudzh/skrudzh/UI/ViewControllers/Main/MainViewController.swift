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
    
    @IBOutlet weak var incomeSourcesCollectionView: UICollectionView!
    @IBOutlet weak var addIncomeSourceButton: UIButton!
    @IBOutlet weak var incomeSourcesActivityIndicator: UIView!
    @IBOutlet weak var incomeSourcesLoader: UIImageView!
    
    @IBOutlet weak var expenseSourcesCollectionView: UICollectionView!
    @IBOutlet weak var addExpenseSourceButton: UIButton!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.mainNavBarColor
    }
    
    @IBAction func didTapAddIncomeSourceButton(_ sender: Any) {
    }
    
    @IBAction func didTapAddExpenseSourceButton(_ sender: Any) {
    }
    
    @IBAction func didTapJoyBasket(_ sender: Any) {
        viewModel.basketsViewModel.selectBasketBy(basketType: .joy)
        viewModel.basketsViewModel.append(cents: 1, basketType: .joy)
        updateBasketsUI()
    }
    
    @IBAction func didTapRiskBasket(_ sender: Any) {
        viewModel.basketsViewModel.selectBasketBy(basketType: .risk)
        viewModel.basketsViewModel.append(cents: 1, basketType: .risk)
        updateBasketsUI()
    }
    
    @IBAction func didTapSafeBasket(_ sender: Any) {
        viewModel.basketsViewModel.selectBasketBy(basketType: .safe)
        viewModel.basketsViewModel.append(cents: 1, basketType: .safe)
        updateBasketsUI()
    }
    
    private func loadData() {
        loadIncomeSources()
        loadExpenseSources()
        loadBaskets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "ShowIncomeSourceCreationScreen",
            let destinationNavigationController = segue.destination as? UINavigationController,
            let destination = destinationNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
            destination.set(delegate: self)
        } else if  segue.identifier == "ShowExpenseSourceCreationScreen",
            let destinationNavigationController = segue.destination as? UINavigationController,
            let destination = destinationNavigationController.topViewController as? ExpenseSourceEditInputProtocol {
            
            destination.set(delegate: self)
        }
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
        loadIncomeSources(scrollToEndWhenUpdated: true)
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
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки источников доходов", theme: .error)
        }.finally {
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
    
    private func didSelectIncomeSource(at indexPath: IndexPath) {
        if  let selectedIncomeSource = viewModel.incomeSourceViewModel(at: indexPath)?.incomeSource,
            let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController,
            let incomeSourceEditViewController = incomeSourceEditNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
            incomeSourceEditViewController.set(delegate: self)
            incomeSourceEditViewController.set(incomeSource: selectedIncomeSource)
            
            present(incomeSourceEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func incomeSourceCollectionViewCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = incomeSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "IncomeSourceCollectionViewCell",
                                                                         for: indexPath) as? IncomeSourceCollectionViewCell,
              let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = incomeSourceViewModel
        return cell
    }
}

extension MainViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        loadExpenseSources(scrollToEndWhenUpdated: true)
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
        if  let selectedExpenseSource = viewModel.expenseSourceViewModel(at: indexPath)?.expenseSource,
            let expenseSourceEditNavigationController = router.viewController(.ExpenseSourceEditNavigationController) as? UINavigationController,
            let expenseSourceEditViewController = expenseSourceEditNavigationController.topViewController as? ExpenseSourceEditInputProtocol {
            
            expenseSourceEditViewController.set(delegate: self)
            expenseSourceEditViewController.set(expenseSource: selectedExpenseSource)
            
            present(expenseSourceEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func expenseSourceCollectionViewCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseSourceCollectionViewCell",
                                                                          for: indexPath) as? ExpenseSourceCollectionViewCell,
            let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = expenseSourceViewModel
        return cell
    }
}

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case incomeSourcesCollectionView:   return 1
        case expenseSourcesCollectionView:  return 1
        default:                            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case incomeSourcesCollectionView:   return viewModel.numberOfIncomeSources
        case expenseSourcesCollectionView:  return viewModel.numberOfExpenseSources
        default:                            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case incomeSourcesCollectionView:   return incomeSourceCollectionViewCell(forItemAt: indexPath)
        case expenseSourcesCollectionView:  return expenseSourceCollectionViewCell(forItemAt: indexPath)
        default:                            return UICollectionViewCell()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case incomeSourcesCollectionView:   didSelectIncomeSource(at: indexPath)
        case expenseSourcesCollectionView:  didSelectExpenseSource(at: indexPath)
        default: return
        }
    }
}

extension MainViewController {
    private func setupUI() {
        setupIncomeSourcesCollectionView()
        setupExpenseSourcesCollectionView()
        setupNavigationBar()
        setupMainMenu()
        setupLoaders()
    }
    
    private func setupIncomeSourcesCollectionView() {
        incomeSourcesCollectionView.delegate = self
        incomeSourcesCollectionView.dataSource = self
    }
    
    private func setupExpenseSourcesCollectionView() {
        expenseSourcesCollectionView.delegate = self
        expenseSourcesCollectionView.dataSource = self
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
        set(incomeSourcesActivityIndicator, hidden: true, animated: false)
        set(expenseSourcesActivityIndicator, hidden: true, animated: false)
    }
}

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
    
    private func loadData() {
        loadIncomeSources()
        loadExpenseSources()
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

extension MainViewController {
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
    
    private func set(_ activityIndicator: UIView, hidden: Bool, animated: Bool = true) {
        guard animated else {
            activityIndicator.isHidden = hidden
            return
        }
        UIView.transition(with: activityIndicator,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            activityIndicator.isHidden = hidden
        })
    }
    
    private func update(_ collectionView: UICollectionView, scrollToEnd: Bool = false) {
        let numberOfItems = self.collectionView(collectionView, numberOfItemsInSection: 0)
        collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            collectionView.reloadSections(indexSet)
        }, completion: { _ in
            if scrollToEnd && numberOfItems > 0 {
                collectionView.scrollToItem(at: IndexPath(item: numberOfItems - 1, section: 0),
                                            at: .right,
                                            animated: true)
            }            
        })
    }
}

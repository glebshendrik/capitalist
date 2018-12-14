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
    
    private func loadData(scrollToEndWhenUpdated: Bool = false) {
        messagePresenterManager.showHUD(with: "Загрузка данных")
        firstly {
            viewModel.loadIncomeSources()
        }.done {
            self.updateUI(scrollToEnd: scrollToEndWhenUpdated)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
        }.finally {
            self.messagePresenterManager.dismissHUD()
        }        
    }
    
    private func updateUI(scrollToEnd: Bool = false) {
        incomeSourcesCollectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            self.incomeSourcesCollectionView.reloadSections(indexSet)
        }, completion: { _ in
            if scrollToEnd && self.viewModel.numberOfIncomeSources > 0 {
                self.incomeSourcesCollectionView.scrollToItem(at: IndexPath(item: self.viewModel.numberOfIncomeSources - 1,
                                                                            section: 0),
                                                              at: .right,
                                                              animated: true)
            }
            
        })
    }
}

extension MainViewController : IncomeSourceEditViewControllerDelegate {
    func didCreate() {
        loadData(scrollToEndWhenUpdated: true)
    }
    
    func didUpdate() {
        loadData()
    }
    
    func didRemove() {
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "ShowIncomeSourceCreationScreen",
            let destinationNavigationController = segue.destination as? UINavigationController,
            let destination = destinationNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
            destination.set(delegate: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let selectedIncomeSource = viewModel.incomeSourceViewModel(at: indexPath)?.incomeSource,
            let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController,
            let incomeSourceEditViewController = incomeSourceEditNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
            incomeSourceEditViewController.set(delegate: self)
            incomeSourceEditViewController.set(incomeSource: selectedIncomeSource)
            
            present(incomeSourceEditNavigationController, animated: true, completion: nil)
        }
        
    }
}

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard collectionView == incomeSourcesCollectionView else { return 0 }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView == incomeSourcesCollectionView else { return 0 }
        
        return viewModel.numberOfIncomeSources
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard   collectionView == incomeSourcesCollectionView,
                let cell = incomeSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "IncomeSourceCollectionViewCell", for: indexPath) as? IncomeSourceCollectionViewCell,
                let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
                    
                    return UICollectionViewCell()
        }
        
        cell.viewModel = incomeSourceViewModel
        return cell
    }
    
    
}

extension MainViewController {
    private func setupUI() {
        setupIncomeSourcesCollectionView()
        setupNavigationBar()
        setupMainMenu()
    }
    
    private func setupIncomeSourcesCollectionView() {
        incomeSourcesCollectionView.delegate = self
        incomeSourcesCollectionView.dataSource = self
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
}

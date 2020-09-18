//
//  SubscriptionViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import InfiniteLayout
import ApphudSDK
import PromiseKit
import StoreKit

class SubscriptionViewController : UIViewController, ApplicationRouterDependantProtocol, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var viewModel: SubscriptionViewModel!
    
    @IBOutlet weak var plansCollectionView: UICollectionView!
    @IBOutlet weak var plansPageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = UIFlowManager.reach(point: .subscription)
    }
    
    func setupUI() {        
        setupNavigationBarAppearance()
        setupPlansUI()
        setupNotifications()
    }
    
    private func updateUI() {
        plansCollectionView.reloadData()
    }
    
    func showActivityIndicator() {
        messagePresenterManager.showHUD()
    }
    
    func hideActivityIndicator() {
        messagePresenterManager.dismissHUD()
    }
    
    @objc private func loadData() {
        viewModel.updateProducts()
        updateUI()
        showActivityIndicator()
        _ = firstly {
                viewModel.checkIntroductoryEligibility()
            }.ensure {
                self.updateUI()
                self.hideActivityIndicator()
            }
    }
    
    private func purchase(product: SKProduct) {
        showActivityIndicator()
        _ = firstly {
                viewModel.purchase(product: product)
            }.done {
                if self.isModal || self.isRoot {
                    self.closeButtonHandler()
                }
                else {
                    self.navigationController?.popViewController()
                }
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Подписка оформлена! Теперь у вас неограниченный доступ!", comment: ""), theme: .success, duration: .normal)
            }.catch { error in
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Невозможно оформить подписку", comment: ""), theme: .error, duration: .short)
            }.finally {
                self.hideActivityIndicator()
            }
    }
    
    private func restore() {
        showActivityIndicator()
        _ = firstly {
                viewModel.restore()
            }.done {
                if self.isModal || self.isRoot {
                    self.closeButtonHandler()
                }
                else {
                    self.navigationController?.popViewController()
                }
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Подписка восстановлена! Теперь у вас снова неограниченный доступ!", comment: ""), theme: .success, duration: .normal)
            }.catch { error in
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Невозможно восстановить подписку", comment: ""), theme: .error, duration: .short)
            }.finally {
                self.hideActivityIndicator()
            }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Apphud.didFetchProductsNotification(), object: nil)
    }
    
    private func setupPlansUI() {
        plansCollectionView.delegate = self
        plansCollectionView.dataSource = self
    }
}

extension SubscriptionViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSubscriptionPlans
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionPlanCollectionViewCell", for: indexPath) as? SubscriptionPlanCollectionViewCell,
            let subscriptionPlanViewModel = viewModel.subscriptionPlanViewModel(by: indexPath) else { return UICollectionViewCell() }
        
        cell.viewModel = subscriptionPlanViewModel
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        plansPageControl.currentPage = indexPath.item
    }
}

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
import UPCarouselFlowLayout

class SubscriptionViewController : UIViewController, ApplicationRouterDependantProtocol, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var viewModel: SubscriptionViewModel!
    
    @IBOutlet weak var plansCollectionView: UICollectionView!
    @IBOutlet weak var plansPageControl: UIPageControl!
    
    var privacyURLString: String {
        return NSLocalizedString("privacy policy url", comment: "privacy policy url")
    }
    
    var termsURLString: String {
        return NSLocalizedString("terms of service url", comment: "terms of service url")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        setupPlansUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = UIFlowManager.reach(point: .subscription)
    }
    
    func setupUI() {        
        setupNavigationBar()
        setupPlansUI()
        setupNotifications()
    }
    
    func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.title = NSLocalizedString("Подписка", comment: "")
    }
    
    private func updateUI() {
        plansPageControl.numberOfPages = viewModel.numberOfSubscriptionPlans
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
    
    private func close() {
        if isModal || isRoot {
            closeButtonHandler()
        }
        else {
            navigationController?.popViewController()
        }
    }
    
    private func purchase(product: SKProduct) {
        showActivityIndicator()
        _ = firstly {
                viewModel.purchase(product: product)
            }.done {
                self.close()
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
                self.close()
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
        
        guard let layout = plansCollectionView.collectionViewLayout as? UPCarouselFlowLayout else { return }
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: plansCollectionView.frame.size.width - 64, height: plansCollectionView.frame.size.height)
        layout.sideItemScale = 0.8
        layout.sideItemAlpha = 1.0
        layout.spacingMode = .fixed(spacing: 8)
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
        cell.delegate = self
        return cell
    }
            
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / (scrollView.frame.size.width - 64))
        plansPageControl.currentPage = Int(pageIndex)
        
//        guard   lastPage != plansPageControl.currentPage,
//                let cell = plansCollectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionPlanCollectionViewCell", for: IndexPath(item: plansPageControl.currentPage, section: 0)) as? SubscriptionPlanCollectionViewCell else { return }
//        cell.tableView.scrollToTop()
    }
}

extension SubscriptionViewController : SubscriptionPlanCollectionViewCellDelegate {
    func didTapUnlimitedContinueButton(product: ProductViewModel) {
        purchase(product: product.product)
    }
    
    func didTapPurchaseButton(product: ProductViewModel) {
        purchase(product: product.product)
    }
    
    func didTapFreeContinueButton() {
        close()
    }
    
    func didTapRestorePurchaseButton() {
        restore()
    }
    
    func didTapPrivacyPolicyButton() {
        open(url: privacyURLString)
    }
    
    func didTapTermsOfUseButton() {
        open(url: termsURLString)
    }
    
    func didChangeContent() {
        plansCollectionView.performBatchUpdates({
            plansCollectionView.reloadItems(at: [IndexPath(item: plansPageControl.currentPage, section: 0)])
        })
    }
}

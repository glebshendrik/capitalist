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
import SafariServices

class FeatureDescriptionCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionImageView: UIImageView!
    
    var viewModel: FeatureDescriptionViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        descriptionLabel.text = viewModel?.description
        guard let viewModel = viewModel else { return }
        descriptionImageView.image = UIImage(named: viewModel.imageName)
    }
}

typealias ProductViewContainer = (background: UIView, title: UILabel, subtitle: UILabel, titleContainer: UIView, subtitleContainer: UIView, delimiter: UIView, discountButton: UIButton)

class SubscriptionViewController : FormFieldsTableViewController, ApplicationRouterDependantProtocol, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var viewModel: SubscriptionViewModel!
    
    @IBOutlet weak var featuresCollectionView: InfiniteCollectionView!
    @IBOutlet weak var featuresPageControl: UIPageControl!
    
    @IBOutlet weak var firstProductBackground: UIView!
    @IBOutlet weak var firstProductDiscountButton: UIButton!
    @IBOutlet weak var firstProductTitleLabel: UILabel!
    @IBOutlet weak var firstProductSubtitleLabel: UILabel!
    @IBOutlet weak var firstProductDelimeter: UIView!
    @IBOutlet weak var firstProductSubtitleContainer: UIView!
    @IBOutlet weak var firstProductTitleContainer: UIView!
    
    @IBOutlet weak var secondProductBackground: UIView!
    @IBOutlet weak var secondProductDiscountButton: UIButton!
    @IBOutlet weak var secondProductTitleLabel: UILabel!
    @IBOutlet weak var secondProductSubtitleLabel: UILabel!
    @IBOutlet weak var secondProductDelimeter: UIView!
    @IBOutlet weak var secondProductSubtitleContainer: UIView!
    @IBOutlet weak var secondProductTitleContainer: UIView!
    
    @IBOutlet weak var productsCell: UITableViewCell!
    
    @IBOutlet weak var purchaseSubtitleLabel: UILabel!
    @IBOutlet weak var discountDescriptionLabel: UILabel!
    
    private var productContainers: [SubscriptionProductId : ProductViewContainer] = [:]
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = UIFlowManager.reach(point: .subscription)
    }
    
    override func setupUI() {
        super.setupUI()
        setupNavigationBarAppearance()
        setupFeaturesUI()
        setupProductsUI()
        setupNotifications()
        loadData()
    }
    
    @IBAction func didTapFirstProduct(_ sender: Any) {
        viewModel.selectedProductId = .monthly
        updateUI()
    }
    
    @IBAction func didTapSecondProduct(_ sender: Any) {
        viewModel.selectedProductId = .yearly
        updateUI()
    }
        
    @IBAction func didTapContinueButton(_ sender: Any) {
        purchase()
    }
    
    @IBAction func didTapRestoreButton(_ sender: Any) {
        restore()
    }
    
    @IBAction func didTapTermsButton(_ sender: Any) {
        show(url: viewModel.termsURLString)
    }
    
    @IBAction func didTapPrivacyButton(_ sender: Any) {
        show(url: viewModel.privacyURLString)
    }
    
    @objc private func loadData() {
        viewModel.updateProducts()
        updateUI(reload: false)
        showActivityIndicator()
        _ = firstly {
                viewModel.checkIntroductoryEligibility()
            }.ensure {
                self.updateUI(reload: false)
                self.hideActivityIndicator()
            }
    }
    
    private func purchase() {
        showActivityIndicator()
        _ = firstly {
                viewModel.purchase()
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
    
    private func setupFeaturesUI() {
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        featuresCollectionView.isItemPagingEnabled = true
        featuresPageControl.numberOfPages = viewModel.numberOfFeatureDescriptions
        scheduledCarouselTimerWithTimeInterval()
    }
    
    private func scheduledCarouselTimerWithTimeInterval() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.showNextFeatureDescription()
        }
    }
    
    @objc private func showNextFeatureDescription() {
        
        guard var currentPage = featuresCollectionView.centeredIndexPath?.row else { return }
        if currentPage > featuresCollectionView.numberOfItems(inSection: 0) - 2 {
           currentPage = 0
        } else {
           currentPage = currentPage + 1
        }
        featuresCollectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func setupProductsUI() {
        productContainers = [.monthly : (background: firstProductBackground,
                                         title: firstProductTitleLabel,
                                         subtitle: firstProductSubtitleLabel,
                                         titleContainer: firstProductTitleContainer,
                                         subtitleContainer: firstProductSubtitleContainer,
                                         delimiter: firstProductDelimeter,
                                         discountButton: firstProductDiscountButton),
                             .yearly : (background: secondProductBackground,
                                        title: secondProductTitleLabel,
                                        subtitle: secondProductSubtitleLabel,
                                        titleContainer: secondProductTitleContainer,
                                        subtitleContainer: secondProductSubtitleContainer,
                                        delimiter: secondProductDelimeter,
                                        discountButton: secondProductDiscountButton)]
    }
    
    private func updateUI(reload: Bool = true) {
        updatePurchaseUI()
        updateDiscountDescriptionUI()
        updateProductUI(by: .monthly)
        updateProductUI(by: .yearly)
        if reload {
            updateTable(animated: false)
        }
    }
    
    private func updatePurchaseUI() {
        purchaseSubtitleLabel.text = viewModel.selectedProduct?.purchaseTitle
    }
    
    private func updateDiscountDescriptionUI() {
        discountDescriptionLabel.text = viewModel.selectedProduct?.discountDescription
    }
    
    private func updateProductUI(by id: SubscriptionProductId) {
        guard let productViewModel = viewModel.productViewModel(by: id) else {
            return
        }
        productContainers[id]?.background.borderColor = UIColor.by(.blue1)
        productContainers[id]?.background.borderWidth = productViewModel.isSelected ? 3.0 : 0.0
        productContainers[id]?.title.text = productViewModel.pricePerPeriod
        productContainers[id]?.subtitle.text = productViewModel.trialTitle
        productContainers[id]?.subtitleContainer.isHidden = !productViewModel.hasTrial
        productContainers[id]?.delimiter.isHidden = !productViewModel.hasTrial
        productContainers[id]?.discountButton.isHidden = !productViewModel.hasDiscount
        productContainers[id]?.discountButton.setTitle(productViewModel.discountTitle, for: .normal)
    }
        
    private func show(url: String) {
        guard let url = URL(string: url) else { return }
        let browser = SFSafariViewController(url: url)
        browser.modalPresentationStyle = .popover
        modal(browser)
    }
}

extension SubscriptionViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfFeatureDescriptions
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeatureDescriptionCollectionViewCell", for: featuresCollectionView.indexPath(from: indexPath)) as? FeatureDescriptionCollectionViewCell,
                let featureDescriptionViewModel = viewModel.featureDescriptionViewModel(by: featuresCollectionView.indexPath(from: indexPath)) else { return UICollectionViewCell() }
        
        cell.viewModel = featureDescriptionViewModel
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        featuresPageControl.currentPage = featuresCollectionView.indexPath(from: indexPath).item
    }
}

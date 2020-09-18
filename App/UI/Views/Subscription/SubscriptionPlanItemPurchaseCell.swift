//
//  SubscriptionPlanItemPurchaseCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

typealias ProductViewContainer = (background: UIView, title: UILabel, subtitle: UILabel, titleContainer: UIView, subtitleContainer: UIView, delimiter: UIView, discountButton: UIButton)

protocol SubscriptionPlanItemPurchaseCellDelegate : class {
    func didTapPurchaseButton(product: ProductViewModel)
}

class SubscriptionPlanItemPurchaseCell : UITableViewCell {
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
    
    @IBOutlet weak var purchaseTitleLabel: UILabel!
    @IBOutlet weak var purchaseSubtitleLabel: UILabel!
    @IBOutlet weak var discountDescriptionLabel: UILabel!
    
    
    weak var delegate: SubscriptionPlanItemPurchaseCellDelegate?
    
    private var productContainers: [SubscriptionProduct : ProductViewContainer] = [:]

    
    var viewModel: PlanPurchaseItemViewModel? = nil {
        didSet {
            updateUI()
        }
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
        guard let product = viewModel?.selectedProductViewModel else { return }
        delegate?.didTapPurchaseButton(product: product)
    }
    
    func updateUI() {        
        updatePurchaseUI()
        updateDiscountDescriptionUI()
        setupProductsUI()
        updateProductUI(by: .monthly)
        updateProductUI(by: .yearly)
    }
    
    private func updatePurchaseUI() {
        purchaseSubtitleLabel.text = viewModel.selectedProduct?.purchaseTitle
    }
    
    private func updateDiscountDescriptionUI() {
        discountDescriptionLabel.text = viewModel.selectedProduct?.discountDescription
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
    
    private func updateProductUI(by id: SubscriptionProduct) {
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
    
}

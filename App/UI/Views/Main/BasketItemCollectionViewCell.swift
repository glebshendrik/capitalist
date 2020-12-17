//
//  BasketItemCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 24/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class BasketItemCollectionViewCell : TransactionableCell {
    lazy var icon: IconView = { return IconView() }()
    lazy var progress: BasketItemProgress = { return BasketItemProgress() }()
    lazy var itemDescription: BasketItemDescription = { return BasketItemDescription() }()
    
    var progressContainerWidth: CGFloat {
        return 64.0
    }
    
    override func setupUI() {
        setupIcon()
        setupProgress()
        setupDescription()
        super.setupUI()
    }
    
    func setupIcon() {
        icon.backgroundViewColor = UIColor.by(.black2)
        icon.backgroundCornerRadius = 4
        icon.iconTintColor = UIColor.by(.white100)        
        icon.vectorIconMode = .compact
        contentView.addSubview(icon)
    }
    
    func setupProgress() {
        progress.backgroundCornerRadius = 4        
        contentView.addSubview(progress)
    }
    
    func setupDescription() {
        itemDescription.titleColor = UIColor.by(.white64)
        itemDescription.amountColor = UIColor.by(.white100)
        itemDescription.subAmountColor = UIColor.by(.white64)
        contentView.addSubview(itemDescription)
    }
    
    override func setupSelectionIndicator() {
        selectionIndicator.isHidden = true
        selectionIndicator.backgroundColor = UIColor.by(.blue1)
        icon.backgroundView.insertSubview(selectionIndicator, at: 0)
    }
    
    override func setupConstraints() {
        setupDeleteButtonConstraints()
        setupIconConstraints()
        setupProgressConstraints()
        setupDescriptionConstraints()
        setupEditButtonConstraints()
        setupSelectionIndicatorConstraints()
    }
    
    override func setupDeleteButtonConstraints() {
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.bottom.equalTo(icon.snp.top).offset(14)
            make.left.equalTo(icon.snp.right).offset(-14)
            make.width.height.equalTo(16)
        }
    }
    
    func setupIconConstraints() {
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupProgressConstraints() {
        progress.snp.makeConstraints { make in
            make.width.equalTo(progressContainerWidth)
            make.height.equalTo(14)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(icon.snp.bottom).offset(0)
        }
    }
    
    func setupDescriptionConstraints() {
        itemDescription.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(6)
            make.bottom.greaterThanOrEqualToSuperview().offset(-7)
            make.left.right.equalToSuperview()
        }
    }
    
    override func setupEditButtonConstraints() {
        editButton.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(-14)
            make.left.equalTo(icon.snp.right).offset(-14)
            make.width.height.equalTo(16)
        }
    }
    
    override func updateUI() {
        updateIcon()
        updateProgress()
        updateDescription()
        super.updateUI()
    }
    
    func updateIcon() {
        icon.vectorIconMode = .compact
    }
    
    func updateProgress() {
    }
    
    
    func updateDescription() {
    }
    
    func iconBackgroundColor(basketType: BasketType) -> UIColor {
        switch basketType {
        case .joy:
            return UIColor.by(.brandExpense)
        case .safe:
            return UIColor.by(.brandSafe)
        case .risk:
            return UIColor.by(.brandRisk)
        }
    }
    
    func progressColor(basketType: BasketType, completed: Bool) -> UIColor {
        switch (basketType, completed) {
        case (.joy, false):
            return UIColor.by(.white40)
        case (.joy, true):
            return UIColor.by(.red1)
        case (.safe, _):
            return UIColor.by(.green24)
        case (.risk, _):
            return UIColor.by(.purple24)
        }
    }
    
    func progressBackgroundColor(basketType: BasketType) -> UIColor {
        switch basketType {
        case .joy:
            return UIColor.by(.gray2)
        case .safe:
            return UIColor.by(.green64)
        case .risk:
            return UIColor.by(.purple64)
        }
    }
}

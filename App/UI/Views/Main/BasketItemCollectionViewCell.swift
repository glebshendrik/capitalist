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
    lazy var icon: BasketItemIcon = { return BasketItemIcon() }()
    lazy var progress: BasketItemProgress = { return BasketItemProgress() }()
    lazy var itemDescription: BasketItemDescription = { return BasketItemDescription() }()
    
    var progressContainerWidth: CGFloat {
        return 48.0
    }
    
    override func setupUI() {
        setupIcon()
        setupProgress()
        setupDescription()
        super.setupUI()
    }
    
    func setupIcon() {
        icon.backgroundColor = UIColor.by(.dark1F263E)
        icon.backgroundCornerRadius = 4
        icon.iconTintColor = UIColor.by(.textFFFFFF)
        contentView.addSubview(icon)
    }
    
    func setupProgress() {
        progress.backgroundCornerRadius = 4
        progress.backgroundColor = UIColor.by(.textFFFFFF)
        contentView.addSubview(progress)
    }
    
    func setupDescription() {
        itemDescription.titleColor = UIColor.by(.text9EAACC)
        itemDescription.amountColor = UIColor.by(.textFFFFFF)
        itemDescription.subAmountColor = UIColor.by(.text9EAACC)
        contentView.addSubview(itemDescription)
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
            make.top.equalToSuperview()
            make.bottom.equalTo(icon.snp.top).offset(14)
            make.left.equalTo(icon.snp.right).offset(-14)
            make.width.height.equalTo(16)
        }
    }
    
    func setupIconConstraints() {
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupProgressConstraints() {
        progress.snp.makeConstraints { make in
            make.width.equalTo(progressContainerWidth)
            make.height.equalTo(14)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(icon.snp.bottom).offset(6)
        }
    }
    
    func setupDescriptionConstraints() {
        itemDescription.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(8)
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
    
    override func setupSelectionIndicatorConstraints() {
        selectionIndicator.snp.makeConstraints { make in
            make.bottom.equalTo(editButton.snp.bottom)
            make.right.equalTo(editButton.snp.right)
        }
    }
    
    override func updateUI() {
        updateIcon()
        updateProgress()
        updateDescription()
        super.updateUI()
    }
    
    func updateIcon() {
    }
    
    func updateProgress() {
    }
    
    
    func updateDescription() {
    }
    
    func progressColor(basketType: BasketType) -> UIColor {
        switch basketType {
        case .joy:
            return UIColor.by(.joyC2C9E2)
        case .risk:
            return UIColor.by(.riskF2D6FE)
        case .safe:
            return UIColor.by(.safeD7F6E6)
        }
    }
}

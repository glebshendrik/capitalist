//
//  BasketItemCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 24/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class BasketItemCollectionViewCell : UICollectionViewCell, EditableCellProtocol {
    
    public private(set) var didSetupConstraints = false

    lazy var icon: BasketItemIcon = { return BasketItemIcon() }()
    lazy var progress: BasketItemProgress = { return BasketItemProgress() }()
    lazy var itemDescription: BasketItemDescription = { return BasketItemDescription() }()
    lazy var deleteButton: UIButton! = { return EditableCellDeleteButton() }()
    lazy var editButton: UIButton! = { return EditableCellEditButton() }()
    
    var progressContainerWidth: CGFloat {
        return 48.0
    }
    
    var delegate: EditableCellDelegate?
    
    var canDelete: Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        setupUI()
        setNeedsUpdateConstraints()
        updateUI()
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    func setupUI() {
        setupIcon()
        setupProgress()
        setupDescription()
        setupDeleteButton()
        setupEditButton()
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
    
    func setupDeleteButton() {
        (deleteButton as? EditableCellButton)?.didTap {
            self.delegate?.didTapDeleteButton(cell: self)
        }
        contentView.addSubview(deleteButton)
    }
    
    func setupEditButton() {
        (editButton as? EditableCellButton)?.didTap {
            self.delegate?.didTapEditButton(cell: self)
        }
        contentView.addSubview(editButton)
    }
    
    func setupConstraints() {
        setupDeleteButtonConstraints()
        setupIconConstraints()
        setupProgressConstraints()
        setupDescriptionConstraints()
        setupEditButtonConstraints()
    }
    
    func setupDeleteButtonConstraints() {
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
    
    func setupEditButtonConstraints() {
        editButton.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(-14)
            make.left.equalTo(icon.snp.right).offset(-14)
            make.width.height.equalTo(16)
        }
    }
    
    func updateUI() {
        updateIcon()
        updateProgress()
        updateDescription()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        contentView.layoutIfNeeded()
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

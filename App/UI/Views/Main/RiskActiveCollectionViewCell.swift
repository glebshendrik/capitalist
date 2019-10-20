//
//  RiskActiveCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class RiskActiveCollectionViewCell : UICollectionViewCell, EditableCellProtocol {
    
    private var didSetupConstraints = false

    lazy var icon: BasketItemIcon = { return BasketItemIcon() }()
    lazy var progress: BasketItemProgress = { return BasketItemProgress() }()
    lazy var itemDescription: BasketItemDescription = { return BasketItemDescription() }()
    lazy var deleteButton: UIButton! = { return EditableCellDeleteButton() }()
    lazy var editButton: UIButton! = { return UIButton() }()
//    lazy var deleteButton: UIButton! = { return EditableCellDeleteButton() }()
//    lazy var editButton: UIButton! = { return EditableCellEditButton() }()

    var delegate: EditableCellDelegate?
    
    var viewModel: ActiveViewModel? {
        didSet {
            updateUI()
        }
    }
        
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
}

extension RiskActiveCollectionViewCell {
    func setupUI() {
        setupIcon()
        setupProgress()
        setupDescription()
        setupDeleteButton()
        setupEditButton()
    }
    
    private func setupIcon() {
        icon.backgroundCornerRadius = 4
        icon.iconTintColor = UIColor.by(.textFFFFFF)
        icon.defaultIconName = IconCategory.expenseCategoryRisk.defaultIconName    
        icon.backgroundImage = UIImage(named: "risk-background")
        contentView.addSubview(icon)
    }
    
    func setupProgress() {
        progress.backgroundCornerRadius = 4
        progress.backgroundColor = UIColor.by(.textFFFFFF)
        progress.backgroundImage = UIImage(named: "risk-planned-background")
        progress.progressColor = UIColor.by(.riskF2D6FE)
        contentView.addSubview(progress)
    }
    
    func setupDescription() {
        itemDescription.titleColor = UIColor.by(.text9EAACC)
        itemDescription.amountColor = UIColor.by(.textFFFFFF)
        itemDescription.subAmountColor = UIColor.by(.text9EAACC)
        contentView.addSubview(itemDescription)
    }
    
    func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(named: "small-cross-icon"), for: .normal)
        deleteButton.backgroundColor = UIColor.by(.dark404B6F)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
        deleteButton.cornerRadius = 8
        deleteButton.tintColor = UIColor.by(.textFFFFFF)
        contentView.addSubview(deleteButton)
    }
    
    func setupEditButton() {
//        editButton.didTap
        contentView.addSubview(editButton)
    }
    
    @objc func didTapDeleteButton(_ sender: UIButton) {
        delegate?.didTapDeleteButton(cell: self)
    }
    
    @objc func didTapEditButton(_ sender: UIButton) {
        delegate?.didTapEditButton(cell: self)
    }
}

extension RiskActiveCollectionViewCell {
    func updateUI() {
        updateIcon()
        updateProgress()
        updateDescription()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        icon.iconURL = viewModel.iconURL
        icon.isBackgroundHidden = viewModel.isMonthlyPaymentPlanCompleted
    }
    
    func updateProgress() {
        guard let viewModel = viewModel else { return }
        progress.isHidden = !viewModel.areExpensesPlanned
        progress.isBackgroundHidden = !viewModel.isMonthlyPaymentPlanCompleted
        progress.isProgressHidden = viewModel.isMonthlyPaymentPlanCompleted
        progress.progress = CGFloat(viewModel.spendingProgress)
        progress.text = viewModel.planned
        progress.labelColor = viewModel.isMonthlyPaymentPlanCompleted
            ? UIColor.by(.textFFFFFF)
            : UIColor.by(.dark2A314B)
    }
    
    
    func updateDescription() {
        itemDescription.titleText = viewModel?.name
        itemDescription.amountText = viewModel?.investedRounded
        itemDescription.subAmountText = viewModel?.costRounded
        itemDescription.isSubAmountHidden = false
    }
}

extension RiskActiveCollectionViewCell {
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
            make.width.equalTo(46)
            make.height.equalTo(16)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(icon.snp.bottom).offset(6)
        }
    }
    
    func setupDescriptionConstraints() {
        itemDescription.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(11)
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
}


//
//  ExpenseCategoryCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView
import SnapKit

class ExpenseCategoryCollectionViewCell : UICollectionViewCell, EditableCellProtocol {
    
    private var didSetupConstraints = false
    
    lazy var iconContainer: UIView = { return UIView() }()
    lazy var progressView: CircleProgressView = { return CircleProgressView() }()
    lazy var progressRingSplitter: UIView = { return UIView() }()
    lazy var progressCenterContainer: UIView = { return UIView() }()
    lazy var progressCenterImageView: UIImageView = { return UIImageView() }()
    lazy var iconImageView: UIImageView = { return UIImageView() }()
    lazy var plannedContainer: UIView = { return UIView() }()
    lazy var plannedImageBackground: UIImageView = { return UIImageView() }()
    lazy var plannedLabel: UILabel = { return UILabel() }()
    lazy var nameLabel: UILabel = { return UILabel() }()
    lazy var spentLabel: UILabel = { return UILabel() }()
    lazy var profitLabel: UILabel = { return UILabel() }()
    lazy var deleteButton: UIButton! = { return UIButton() }()
    lazy var editButton: UIButton! = { return UIButton() }()

    var delegate: EditableCellDelegate?
    
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
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

extension ExpenseCategoryCollectionViewCell {
    func setupUI() {
        setupIconContainer()
        setupProgressView()
        setupProgressRingSplitter()
        setupProgressCenterContainer()
        setupProgressCenterImageView()
        setupIcon()
        setupPlannedContainer()
        setupPlannedImageBackground()
        setupPlannedLabel()
        setupNameLabel()
        setupSpentLabel()
        setupProfitLabel()
        setupDeleteButton()
        setupEditButton()
    }
    
    func setupIconContainer() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = .clear
        contentView.addSubview(iconContainer)
    }
    
    func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackWidth = 1
        progressView.backgroundColor = .clear
        progressView.transform = CGAffineTransform(rotationAngle: -120 * CGFloat.pi / 180)
        iconContainer.addSubview(progressView)
    }
    
    func setupProgressRingSplitter() {
        progressRingSplitter.translatesAutoresizingMaskIntoConstraints = false
        progressRingSplitter.cornerRadius = 25
        progressRingSplitter.backgroundColor = UIColor.by(.dark333D5B)
        iconContainer.addSubview(progressRingSplitter)
    }
    
    func setupProgressCenterContainer() {
        progressCenterContainer.translatesAutoresizingMaskIntoConstraints = false
        progressCenterContainer.cornerRadius = 24
        progressCenterContainer.backgroundColor = UIColor.by(.dark1F263E)
        iconContainer.addSubview(progressCenterContainer)
    }
    
    func setupProgressCenterImageView() {
        progressCenterImageView.translatesAutoresizingMaskIntoConstraints = false
        progressCenterImageView.cornerRadius = 24
        progressCenterContainer.addSubview(progressCenterImageView)
    }
    
    func setupIcon() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = UIColor.by(.textFFFFFF)
        iconImageView.contentMode = .scaleAspectFit
        progressCenterContainer.addSubview(iconImageView)
    }
    
    func setupPlannedContainer() {
        plannedContainer.translatesAutoresizingMaskIntoConstraints = false
        plannedContainer.cornerRadius = 4
        plannedContainer.backgroundColor = UIColor.by(.textFFFFFF)
        contentView.addSubview(plannedContainer)
    }
    
    func setupPlannedImageBackground() {
        plannedImageBackground.translatesAutoresizingMaskIntoConstraints = false
        plannedContainer.addSubview(plannedImageBackground)
    }
    
    func setupPlannedLabel() {
        plannedLabel.translatesAutoresizingMaskIntoConstraints = false
        plannedLabel.textAlignment = .center
        plannedLabel.font = UIFont(name: "Rubik-Regular", size: 9)
        plannedLabel.adjustsFontSizeToFitWidth = true
        plannedContainer.addSubview(plannedLabel)
    }
    
    func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(name: "Rubik-Regular", size: 11)
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.by(.text9EAACC)
        contentView.addSubview(nameLabel)
    }
    
    func setupSpentLabel() {
        spentLabel.translatesAutoresizingMaskIntoConstraints = false
        spentLabel.font = UIFont(name: "Rubik-Regular", size: 13)
        spentLabel.textColor = UIColor.by(.textFFFFFF)
        spentLabel.textAlignment = .center
        contentView.addSubview(spentLabel)
    }
    
    func setupProfitLabel() {
        profitLabel.translatesAutoresizingMaskIntoConstraints = false
        profitLabel.font = UIFont(name: "Rubik-Regular", size: 11)
        profitLabel.textColor = UIColor.by(.green68E79B)
        profitLabel.textAlignment = .center
        contentView.addSubview(profitLabel)
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
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(named: "pen-icon"), for: .normal)
        editButton.addTarget(self, action: #selector(didTapEditButton(_:)), for: .touchUpInside)
        editButton.backgroundColor = UIColor.by(.dark404B6F)
        editButton.cornerRadius = 8
        editButton.tintColor = UIColor.by(.textFFFFFF)
        contentView.addSubview(editButton)
    }
    
    @objc func didTapDeleteButton(_ sender: UIButton) {
        delegate?.didTapDeleteButton(cell: self)
    }
    
    @objc func didTapEditButton(_ sender: UIButton) {
        delegate?.didTapEditButton(cell: self)
    }
}

extension ExpenseCategoryCollectionViewCell {
    func updateUI() {
        updateIconContainer()
        updateProgressView()
        updateProgressRingSplitter()
        updateProgressCenterContainer()
        updateProgressCenterImageView()
        updateIcon()
        updatePlannedContainer()
        updatePlannedImageBackground()
        updatePlannedLabel()
        updateNameLabel()
        updateSpentLabel()
        updateProfitLabel()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func updateIconContainer() {
        
    }
    
    func updateProgressView() {
        guard let viewModel = viewModel else { return }
        
        func trackFillColor() -> UIColor {
            guard !viewModel.isSpendingProgressCompleted else {
                return UIColor.by(.dark1F263E)
            }
            
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return UIColor.by(.joy6EEC99)
            case .risk:
                return UIColor.by(.riskC765F0)
            case .safe:
                return UIColor.by(.safe4828D1)
            }
        }
        
        func trackBackgroundColor() -> UIColor {
            guard viewModel.areExpensesPlanned else {
                return .clear
            }
            
            guard !viewModel.isSpendingProgressCompleted else {
                return UIColor.by(.dark1F263E)
            }
            
            return trackFillColor().withAlphaComponent(0.5)
        }
        
        progressView.progress = viewModel.spendingProgress * 0.67
        progressView.trackBackgroundColor = trackBackgroundColor()
        progressView.trackFillColor = trackFillColor()
        progressView.centerFillColor = .clear
        progressView.trackBorderColor = .clear
        progressView.borderColor = .clear
    }
    
    func updateProgressRingSplitter() {
        guard let viewModel = viewModel else { return }
        progressRingSplitter.isHidden = !viewModel.areExpensesPlanned
    }
    
    func updateProgressCenterContainer() {
        
    }
    
    func updateProgressCenterImageView() {
        guard let viewModel = viewModel else { return }
        
        progressCenterImageView.isHidden = viewModel.isSpendingProgressCompleted
        
        func centerImage() -> UIImage? {
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return UIImage(named: "joy-background")
            case .risk:
                return UIImage(named: "risk-background")
            case .safe:
                return UIImage(named: "safe-background")
            }
        }
        
        progressCenterImageView.image = centerImage()
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        iconImageView.setImage(with: viewModel.iconURL,
                               placeholderName: viewModel.expenseCategory.basketType.iconCategory.defaultIconName,
                               renderingMode: .alwaysTemplate)
    }
    
    func updatePlannedContainer() {
        guard let viewModel = viewModel else { return }
        plannedContainer.isHidden = !viewModel.areExpensesPlanned
    }
    
    func updatePlannedImageBackground() {
        guard let viewModel = viewModel else { return }
        plannedImageBackground.isHidden = !viewModel.isSpendingProgressCompleted
        func plannedBackground() -> UIImage? {
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return UIImage(named: "joy-planned-background")
            case .risk:
                return UIImage(named: "risk-planned-background")
            case .safe:
                return UIImage(named: "safe-planned-background")
            }
        }
        plannedImageBackground.image = plannedBackground()
    }
    
    func updatePlannedLabel() {
        guard let viewModel = viewModel else { return }
        plannedLabel.text = viewModel.planned
        plannedLabel.textColor = viewModel.isSpendingProgressCompleted
            ? UIColor.by(.textFFFFFF)
            : UIColor.by(.dark2A314B)
    }
    
    func updateNameLabel() {
        nameLabel.text = viewModel?.name
    }
    
    func updateSpentLabel() {
        spentLabel.text = viewModel?.spentRounded
    }
    
    func updateProfitLabel() {
        guard let viewModel = viewModel else { return }
        profitLabel.isHidden = !viewModel.hasProfit
        profitLabel.text = viewModel.profit
        if viewModel.isProfitNegative {
            profitLabel.textColor = UIColor.by(.redE77768)
        }
        else {
            profitLabel.textColor = UIColor.by(.green68E79B)
        }
    }
}

extension ExpenseCategoryCollectionViewCell {
    func setupConstraints() {
        setupIconContainerConstraints()
        setupProgressViewConstraints()
        setupProgressRingSplitterConstraints()
        setupProgressCenterContainerConstraints()
        setupProgressCenterImageViewConstraints()
        setupIconConstraints()
        setupPlannedContainerConstraints()
        setupPlannedImageBackgroundConstraints()
        setupPlannedLabelConstraints()
        setupNameLabelConstraints()
        setupSpentLabelConstraints()
        setupProfitLabelConstraints()
        setupDeleteButtonConstraints()
        setupEditButtonConstraints()
    }
    
    func setupIconContainerConstraints() {
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupProgressViewConstraints() {
        progressView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func setupProgressRingSplitterConstraints() {
        progressRingSplitter.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    func setupProgressCenterContainerConstraints() {
        progressCenterContainer.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.center.equalToSuperview()
        }
    }
    
    func setupProgressCenterImageViewConstraints() {
        progressCenterImageView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func setupIconConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(20)
            make.center.equalToSuperview()
        }
    }
    
    func setupPlannedContainerConstraints() {
        plannedContainer.snp.makeConstraints { make in
            make.width.equalTo(46)
            make.height.equalTo(16)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(iconContainer.snp.bottom).offset(2)
        }
        
    }
    
    func setupPlannedImageBackgroundConstraints() {
        plannedImageBackground.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func setupPlannedLabelConstraints() {
        plannedLabel.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func setupNameLabelConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func setupSpentLabelConstraints() {
        spentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(1)
            make.left.right.equalToSuperview()
        }
        spentLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        spentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func setupProfitLabelConstraints() {
        profitLabel.snp.makeConstraints { make in
            make.top.equalTo(spentLabel.snp.bottom).offset(0)
            make.bottom.greaterThanOrEqualToSuperview().offset(-7)
            make.left.right.equalToSuperview()
        }
        profitLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        profitLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    func setupDeleteButtonConstraints() {
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(iconContainer.snp.top).offset(14)
            make.left.equalTo(iconContainer.snp.right).offset(-14)
            make.width.height.equalTo(16)
        }
    }
    
    func setupEditButtonConstraints() {
        editButton.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(-14)
            make.left.equalTo(iconContainer.snp.right).offset(-14)
            make.width.height.equalTo(16)
        }
    }
}

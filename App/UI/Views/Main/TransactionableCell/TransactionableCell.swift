//
//  TransactionableCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 05.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import Haptica

protocol EditableCellProtocol {
    var deleteButton: UIButton! { get }
    var editButton: UIButton! { get }
    var canDelete: Bool { get }

    func setDeleteButton(enabled: Bool, animated: Bool)
    func setEditButton(enabled: Bool, animated: Bool)
}

protocol SelectableCellProtocol {
    var selectionIndicator: UIView! { get }
    var canSelect: Bool { get }

    func setSelectionIndicator(hidden: Bool, animated: Bool)
}

protocol TransactionableCellDelegate : class {
    func canDelete(cell: TransactionableCellProtocol) -> Bool
    func canSelect(cell: TransactionableCellProtocol) -> Bool
    func didTapDeleteButton(cell: TransactionableCellProtocol)
    func didTapEditButton(cell: TransactionableCellProtocol)
}

protocol TransactionableCellProtocol : EditableCellProtocol, SelectableCellProtocol {
    var delegate: TransactionableCellDelegate? { get set }

    var transactionable: Transactionable? { get }
}

class TransactionableCell : UICollectionViewCell, TransactionableCellProtocol {
    lazy var deleteButton: UIButton! = { return EditableCellDeleteButton() }()
    lazy var editButton: UIButton! = { return EditableCellEditButton() }()
    lazy var selectionIndicator: UIView! = { return UIView() }()
    weak var delegate: TransactionableCellDelegate?
        
    public private(set) var didSetupConstraints = false
    
    var transactionable: Transactionable? { return nil }
    
    var canDelete: Bool {
        guard let delegate = delegate else { return false }
        return delegate.canDelete(cell: self)
    }
    
    var canSelect: Bool {
        guard let delegate = delegate else { return false }
        return delegate.canSelect(cell: self)
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
    
    func setupUI() {
        setupDeleteButton()
        setupEditButton()
        setupSelectionIndicator()
    }
    
    func updateUI() {
        updateSelectionIndicator()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        contentView.layoutIfNeeded()
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    func setupConstraints() {
        setupDeleteButtonConstraints()
        setupEditButtonConstraints()
        setupSelectionIndicatorConstraints()
    }
    
    func setupDeleteButtonConstraints() {
        deleteButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
        }
    }
    
    func setupEditButtonConstraints() {
        editButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
        }
    }
    
    func setupSelectionIndicatorConstraints() {
        selectionIndicator.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
    }
    
    func setupDeleteButton() {
        (deleteButton as? EditableCellButton)?.didTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapDeleteButton(cell: self)
        }
        contentView.addSubview(deleteButton)
    }
    
    func setupEditButton() {
        (editButton as? EditableCellButton)?.didTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapEditButton(cell: self)
        }
        contentView.addSubview(editButton)
    }
    
    func setupSelectionIndicator() {
        selectionIndicator.isHidden = true
        contentView.addSubview(selectionIndicator)
    }
    
    func updateSelectionIndicator() {
        guard let transactionable = transactionable else {
            set(selected: false, animated: false)
            return
        }
        set(selected: transactionable.isSelected, animated: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopWiggling()
    }
    
    func setDeleteButton(enabled: Bool, animated: Bool) {
        set(button: deleteButton, enabled: enabled, animated: animated)
    }
    
    func setEditButton(enabled: Bool, animated: Bool) {
        set(button: editButton, enabled: enabled, animated: animated)
    }
    
    func setSelectionIndicator(hidden: Bool, animated: Bool) {
        set(view: selectionIndicator, hidden: hidden, animated: animated)
    }
    
    private func set(button: UIButton, enabled: Bool, animated: Bool) {
        button.isEnabled = enabled
        set(view: button, hidden: !enabled, animated: animated)
    }
    
    private func set(view: UIView, hidden: Bool, animated: Bool) {
        if animated {
            UIView.transition(with: view,
                              duration: 0.1,
                              options: .transitionCrossDissolve,
                              animations: {
                view.isHidden = hidden
            })
        }
        else {
            view.isHidden = hidden
        }
    }
}

extension UICollectionViewCell {
    func set(editing: Bool, animated: Bool = true) {
        guard let editableCell = self as? TransactionableCellProtocol else { return }
        editing
            ? startWiggling()
            : stopWiggling()
        editableCell.setDeleteButton(enabled: editing && editableCell.canDelete, animated: animated)
        editableCell.setEditButton(enabled: editing, animated: animated)
        if editing {
            editableCell.setSelectionIndicator(hidden: true, animated: animated)
        }
    }
    
    func set(selected: Bool, animated: Bool = true) {
        guard let editableCell = self as? TransactionableCellProtocol else { return }
        
        selected
            ? scaleDown(animated: animated)
            : unscale(animated: animated)
        
        editableCell.setSelectionIndicator(hidden: !selected, animated: animated)
        if selected {
            haptic()
            editableCell.setDeleteButton(enabled: false, animated: animated)
            editableCell.setEditButton(enabled: false, animated: animated)
        }
    }
    
    func startWiggling() {
        guard contentView.layer.animation(forKey: "wiggle") == nil else { return }
        guard contentView.layer.animation(forKey: "bounce") == nil else { return }
        
        let angle = 0.02
        
        let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggle.values = [-angle, angle]
        
        wiggle.autoreverses = true
        wiggle.duration = randomInterval(interval: 0.1, variance: 0.025)
        wiggle.repeatCount = Float.infinity
        
        
        contentView.layer.add(wiggle, forKey: "wiggle")
        
        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [2.0, 0.0]
        
        bounce.autoreverses = true
        bounce.duration = randomInterval(interval: 0.12, variance: 0.025)
        bounce.repeatCount = Float.infinity
        
        
        contentView.layer.add(bounce, forKey: "bounce")
    }
    
    func stopWiggling() {
        contentView.layer.removeAllAnimations()
    }
    
    private func randomInterval(interval: TimeInterval, variance: Double) -> TimeInterval {
        return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
    }
}

extension UICollectionViewCell {
    func scaleUp(animated: Bool = true) {
        set(animated: animated, transform: CGAffineTransform(scaleX: 1.1, y: 1.1))
    }
    
    func scaleDown(animated: Bool = true) {
        set(animated: animated, transform: CGAffineTransform(scaleX: 0.9, y: 0.9))
    }
    
    func unscale(animated: Bool = true) {
        set(animated: animated, transform: CGAffineTransform.identity)
    }
    
    func pickUp(animated: Bool = true) {
        set(animated: animated, transform: CGAffineTransform(scaleX: 1.2, y: 1.2), alpha: 0.99)
    }
    
    func putDown(animated: Bool = true, editing: Bool) {
        set(animated: animated, transform: CGAffineTransform.identity, alpha: 1.0) { finished in
            self.set(editing: editing, animated: animated)
        }
    }
    
    private func set(animated: Bool = true, transform: CGAffineTransform, alpha: CGFloat? = nil, completion: ((Bool) -> ())? = nil) {
        if animated {
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: [.allowUserInteraction, .beginFromCurrentState],
                           animations: { () -> Void in
                self.transform = transform
                if let alpha = alpha {
                    self.alpha = alpha
                }
            }, completion: completion)
        }
        else {
            self.transform = transform
            if let alpha = alpha {
                self.alpha = alpha
            }
            completion?(true)
        }
    }
}

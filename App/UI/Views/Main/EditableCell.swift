//
//  EditableCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol EditableCellProtocol {
    var delegate: EditableCellDelegate? { get set }
    var deleteButton: UIButton! { get }
    var editButton: UIButton! { get }    
}

protocol EditableCellDelegate {
    func didTapDeleteButton(cell: EditableCellProtocol)
    func didTapEditButton(cell: EditableCellProtocol)
}

class EditableCell : UICollectionViewCell, EditableCellProtocol {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    var delegate: EditableCellDelegate?
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        delegate?.didTapDeleteButton(cell: self)
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        delegate?.didTapEditButton(cell: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopWiggling()
    }
}

extension UICollectionViewCell {
    func set(editing: Bool) {
        guard let editableCell = self as? EditableCellProtocol else { return }
        editing
            ? startWiggling()
            : stopWiggling()
        
        editableCell.deleteButton.isEnabled = editing
        UIView.transition(with: editableCell.deleteButton,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            editableCell.deleteButton.isHidden = !editing
        })
        
        editableCell.editButton.isEnabled = editing
        UIView.transition(with: editableCell.editButton,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            editableCell.editButton.isHidden = !editing
        })
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

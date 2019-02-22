//
//  EditableCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 22/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

protocol EditableCellDelegate {
    func didTapDeleteButton(cell: EditableCell)
    func didTapEditButton(cell: EditableCell)
}

class EditableCell : UICollectionViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    var delegate: EditableCellDelegate?
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        delegate?.didTapDeleteButton(cell: self)
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        delegate?.didTapEditButton(cell: self)
    }
    
    func set(editing: Bool) {
        editing
            ? startWiggling()
            : stopWiggling()
        
        deleteButton.isEnabled = editing
        UIView.transition(with: deleteButton,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.deleteButton.isHidden = !editing
        })
        
        editButton.isEnabled = editing
        UIView.transition(with: editButton,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.editButton.isHidden = !editing
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopWiggling()
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

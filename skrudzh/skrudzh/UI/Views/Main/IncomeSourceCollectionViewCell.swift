//
//  IncomeSourceCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
}

class IncomeSourceCollectionViewCell : EditableCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        incomeAmountLabel.text = viewModel?.incomesAmount
    }
    
    
}


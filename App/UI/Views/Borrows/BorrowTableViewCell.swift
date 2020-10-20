//
//  BorrowTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import AlamofireImage

class BorrowTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var borrowedAtLabel: UILabel!
    @IBOutlet weak var paydayLabel: UILabel!
    
    var placeholderName: String {        
        return "borrow-default-icon"
    }
        
    var viewModel: BorrowViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.name
        amountLabel.text = viewModel.diplayAmount
        
        borrowedAtLabel.text = viewModel.borrowedAtFormatted
        paydayLabel.text = viewModel.paydayText
                
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = placeholderName
        iconView.iconTintColor = UIColor.by(.white100)
    }
}

//
//  StatisticsEditTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol StatisticsEditTableViewCellDelegate {
    func didTapStatisticsEditButton()
}

class StatisticsEditTableViewCell : UITableViewCell {    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButtonTitleLabel: UILabel!
    
    var delegate: StatisticsEditTableViewCellDelegate?
    
    @IBAction func didTapStatisticsEditButton(_ sender: Any) {
        delegate?.didTapStatisticsEditButton()
    }
}

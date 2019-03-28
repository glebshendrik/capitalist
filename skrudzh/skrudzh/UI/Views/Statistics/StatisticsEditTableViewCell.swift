//
//  StatisticsEditTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

protocol StatisticsEditTableViewCellDelegate {
    func didTapStatisticsEditButton()
}

class StatisticsEditTableViewCell : UITableViewCell {
    var delegate: StatisticsEditTableViewCellDelegate?
    
    @IBAction func didTapStatisticsEditButton(_ sender: Any) {
        delegate?.didTapStatisticsEditButton()
    }
}

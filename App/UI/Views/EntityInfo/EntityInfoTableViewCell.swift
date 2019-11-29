//
//  EntityInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol EntityInfoTableViewCellDelegate : class {
    
}

class EntityInfoTableViewCell : UITableViewCell {
    weak var delegate: EntityInfoTableViewCellDelegate?
    
    var field: EntityInfoField? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
    }
}

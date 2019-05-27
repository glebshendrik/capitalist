//
//  HistoryTransactionsLoadingTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class HistoryTransactionsLoadingTableViewCell : UITableViewCell {
    @IBOutlet weak var loaderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loaderImageView.showLoader()
    }
}

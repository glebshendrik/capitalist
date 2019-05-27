//
//  RearrangeController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class RearrangeController {
    var movingIndexPath: IndexPath? = nil
    var movingCollectionView: UICollectionView? = nil
    var offsetForCollectionViewCellBeingMoved: CGPoint = .zero
}
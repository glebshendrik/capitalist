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
    
    func isMoving(_ collectionView: UICollectionView, indexPath: IndexPath) -> Bool {
        return collectionView == movingCollectionView && indexPath == movingIndexPath
    }
    
    func syncStateOf(_ collectionView: UICollectionView, cell: UICollectionViewCell, at indexPath: IndexPath, editing: Bool, animated: Bool) {
        if collectionView == movingCollectionView {
            if indexPath == movingIndexPath {
                cell.pickUp(animated: animated)
            } else {
                cell.putDown(animated: animated, editing: editing)
            }
        }
    }
}

//
//  RearrangeControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func didRecognizeRearrangeGesture(gesture: UILongPressGestureRecognizer) {
        
        rearrangeController.movingCollectionView = gesture.view as? UICollectionView
        
        guard let movingCollectionView = rearrangeController.movingCollectionView else { return }
        
        let location = gesture.location(in: movingCollectionView)
        
        switch gesture.state {
        case .began:
            if !isEditingItems {
                setEditingItems(true, animated: true)
                completeTransactionInteraction()
                return
            }
            rearrangeController.movingIndexPath = movingCollectionView.indexPathForItem(at: location)
            
            guard let indexPath = rearrangeController.movingIndexPath else { return }
            
            let cell = movingCollectionView.cellForItem(at: indexPath)
            
            movingCollectionView.beginInteractiveMovementForItem(at: indexPath)
            
            if let cell = cell {
                rearrangeController.offsetForCollectionViewCellBeingMoved = offsetOfTouchFrom(recognizer: gesture, inCell: cell)
            }
            
            var location = gesture.location(in: movingCollectionView)
            
            location.x += rearrangeController.offsetForCollectionViewCellBeingMoved.x
            location.y += rearrangeController.offsetForCollectionViewCellBeingMoved.y
            
            movingCollectionView.updateInteractiveMovementTargetPosition(location)
            
            cell?.set(editing: false)
            cell?.pickUp()
        case .changed:
            
            var location = gesture.location(in: movingCollectionView)
            
            location.x += rearrangeController.offsetForCollectionViewCellBeingMoved.x
            location.y += rearrangeController.offsetForCollectionViewCellBeingMoved.y
            
            movingCollectionView.updateInteractiveMovementTargetPosition(location)
        default:
            gesture.state == .ended
                ? movingCollectionView.endInteractiveMovement()
                : movingCollectionView.cancelInteractiveMovement()
            
            guard let indexPath = rearrangeController.movingIndexPath else { return }
            
            let cell = movingCollectionView.cellForItem(at: indexPath)
            
            cell?.putDown(animated: true, editing: isEditingItems)
            rearrangeController.movingIndexPath = nil
        }
        
    }
    
    private func offsetOfTouchFrom(recognizer: UIGestureRecognizer, inCell cell: UICollectionViewCell) -> CGPoint {
        
        let locationOfTouchInCell = recognizer.location(in: cell)
        
        let cellCenterX = cell.frame.width / 2
        let cellCenterY = cell.frame.height / 2
        
        let cellCenter = CGPoint(x: cellCenterX, y: cellCenterY)
        
        var offSetPoint = CGPoint.zero
        
        offSetPoint.y = cellCenter.y - locationOfTouchInCell.y
        offSetPoint.x = cellCenter.x - locationOfTouchInCell.x
        
        return offSetPoint
        
    }
}

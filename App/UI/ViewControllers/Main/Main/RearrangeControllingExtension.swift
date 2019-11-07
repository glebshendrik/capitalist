//
//  RearrangeControllingExtension.swift
//  Three Baskets
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
            if !isEditing {
                setEditing(true, animated: true)
                transactionDraggingElement.isHidden = true
                transactionController.transactionStartedCollectionView = nil
                transactionController.dropCandidateCollectionView = nil
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
            animatePickingUp(cell: cell)
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
            
            animatePuttingDown(cell: cell)
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
    
    private func animatePickingUp(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.alpha = 0.99
            cell?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { finished in
            
        })
    }
    
    private func animatePuttingDown(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.alpha = 1.0
            cell?.transform = CGAffineTransform.identity
        }, completion: { finished in
            cell?.set(editing: true)
        })
    }
}

extension MainViewController {
    func setVisibleCells(editing: Bool) {
        let cells = incomeSourcesCollectionView.visibleCells + expenseSourcesCollectionView.visibleCells + joyExpenseCategoriesCollectionView.visibleCells + riskActivesCollectionView.visibleCells + safeActivesCollectionView.visibleCells
        
        for cell in cells {
            cell.set(editing: editing)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        guard editing != isEditing else { return }
        
        super.setEditing(editing, animated: animated)
        
        viewModel?.set(editing: editing)
        updateCollectionViews()
        updateLongPressureRecognizers()
        updateTotalUI()
        setVisibleCells(editing: editing)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.editDoneButton.alpha = editing ? 1.0 : 0.0
        }) { completed in
//            self.didCreateExpense()
        }
    }
    
    private func updateLongPressureRecognizers() {
        longPressureRecognizers.forEach {
            $0.minimumPressDuration = isEditing ? fastPressDuration : slowPressDuration
        }
    }
}

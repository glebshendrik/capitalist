//
//  TransactionController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol TransactionControllerDelegate {
    var mainView: UIView { get }
    var isEditingItems: Bool { get }
    var isSelecting: Bool { get }
    
    func didSetSource(cell: UICollectionViewCell?, animated: Bool)
    func didSetDestination(cell: UICollectionViewCell?, animated: Bool)
    func didSetNormal(cell: UICollectionViewCell?, animated: Bool)
    
    func didSetTransactionables(source: TransactionSource, destination: TransactionDestination)
}

class TransactionController {
    
    let delegate: TransactionControllerDelegate
    
    var isTransactionStarted: Bool {
        return sourceCollectionView != nil
    }
    
    var startedLocation: CGPoint? = nil {
        didSet {
            currentLocation = nil
            maxDistance = 0
        }
    }
    
    var currentLocation: CGPoint? = nil {
        didSet {
            guard let currentLocation = currentLocation, let startedLocation = startedLocation else { return }
            maxDistance = max(currentLocation.distance(from: startedLocation), maxDistance)
        }
    }
    
    var maxDistance: CGFloat = 0
    
    var wentFarFromStart: Bool {
        return maxDistance > 3
    }
    
    var sourceLocation: CGPoint? = nil
    
    var sourceCollectionView: UICollectionView? = nil {
        didSet {
            if sourceCollectionView != oldValue {
                sourceIndexPath = nil
                sourceLocation = nil
            }
        }
    }
    
    var sourceIndexPath: IndexPath? = nil {
        didSet {
            if sourceIndexPath != oldValue {
                sourceCell = nil
            }
        }
    }
    
    var sourceCell: UICollectionViewCell? = nil {
        didSet {
            if sourceCell != oldValue {
                delegate.didSetNormal(cell: oldValue, animated: true)
                delegate.didSetSource(cell: sourceCell, animated: true)
            }
        }
    }
    
    var destinationCollectionView: UICollectionView? = nil {
        didSet {
            if destinationCollectionView != oldValue {
                initializeWaitingAtTheEdge()
                destinationIndexPath = nil
            }
        }
    }
    
    var destinationIndexPath: IndexPath? = nil {
        didSet {
            if destinationIndexPath != oldValue {
                destinationCell = nil
            }
        }
    }
    
    var destinationCell: UICollectionViewCell? = nil {
        didSet {
            if destinationCell != oldValue {
                delegate.didSetNormal(cell: oldValue, animated: true)
                delegate.didSetDestination(cell: destinationCell, animated: true)
            }
        }
    }
    
    var waitingAtTheEdgeTimer: Timer? = nil
    
    var waitingEdge: UIRectEdge? = nil {
        didSet {
            if waitingEdge != oldValue {
                initializeWaitingAtTheEdge()
            } else if waitingEdge == nil  {
                waitingAtTheEdgeTimer?.invalidate()
                waitingAtTheEdgeTimer = nil
            }
        }
    }
    
    init(delegate: TransactionControllerDelegate) {
        self.delegate = delegate
    }
    
    func select(collectionView: UICollectionView, indexPath: IndexPath, transactionPart: TransactionPart?) {
        guard   let cell = collectionView.cellForItem(at: indexPath) as? TransactionableCell,
                let transactionable = cell.transactionable else { return }
        if sourceCell == nil && destinationCell == nil {
            sourceCollectionView = collectionView
            sourceIndexPath = indexPath            
//            transactionable.isSelected = true
            sourceCell = cell
        }
        else if sourceCell == nil {
            sourceCollectionView = collectionView
            sourceIndexPath = indexPath
//            transactionable.isSelected = true
            sourceCell = cell
        }
        else if destinationCell == nil {
            destinationCollectionView = collectionView
            destinationIndexPath = indexPath
//            transactionable.isSelected = true
            destinationCell = cell
        }
        
        if  let sourceCell = sourceCell as? TransactionableCell,
            let destinationCell = destinationCell as? TransactionableCell,
            let source = sourceCell.transactionable as? TransactionSource,
            let destination = destinationCell.transactionable as? TransactionDestination {
            delegate.didSetTransactionables(source: source, destination: destination)
        }
    }
    
    func updateWaitingEdge(at location: CGPoint, in view: UIView, locationInCollectionView: CGPoint, direction: UICollectionView.ScrollDirection?) {
        waitingEdge = getWaitingEdge(at: location, in: view, locationInCollectionView: locationInCollectionView, direction: direction)
    }
    
    func syncStateOf(_ collectionView: UICollectionView, cell: UICollectionViewCell, at indexPath: IndexPath, animated: Bool) {
        if collectionView == sourceCollectionView && collectionView == destinationCollectionView {
            if indexPath == sourceIndexPath {
                delegate.didSetSource(cell: cell, animated: animated)
            }
            else if indexPath == destinationIndexPath {
                delegate.didSetDestination(cell: cell, animated: animated)
            }
            else {
                delegate.didSetNormal(cell: cell, animated: animated)
            }
        }
        else if collectionView == sourceCollectionView {
            if indexPath == sourceIndexPath {
                delegate.didSetSource(cell: cell, animated: animated)
            }
            else {
                delegate.didSetNormal(cell: cell, animated: animated)
            }
        }
        else if collectionView == destinationCollectionView {
            if indexPath == destinationIndexPath {
                delegate.didSetDestination(cell: cell, animated: animated)
            }
            else {
                delegate.didSetNormal(cell: cell, animated: animated)
            }
        }
    }
    
    private func getWaitingEdge(at location: CGPoint, in view: UIView, locationInCollectionView: CGPoint, direction: UICollectionView.ScrollDirection?) -> UIRectEdge? {
        guard let direction = direction else { return nil }
        let horizontalEdgeRatio: CGFloat = 0.15
        let verticalEdgeRatio: CGFloat = 0.2
        if direction == .horizontal && location.x < (view.frame.size.width * horizontalEdgeRatio) {
            return .left
        }
        if direction == .horizontal && location.x > (view.frame.size.width * (1 - horizontalEdgeRatio)) {
            return .right
        }
        guard let collectionView = destinationCollectionView else { return nil }
        if direction == .vertical && locationInCollectionView.y < (collectionView.frame.height * verticalEdgeRatio) {
            return .top
        }
        if direction == .vertical && locationInCollectionView.y > (collectionView.frame.height * (1 - verticalEdgeRatio)) {
            return .bottom
        }
        return nil
    }
    
    private func initializeWaitingAtTheEdge() {
        waitingAtTheEdgeTimer?.invalidate()
        if destinationCollectionView != nil && waitingEdge != nil && !delegate.isEditingItems {
            waitingAtTheEdgeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(changeWaitingPage), userInfo: nil, repeats: false)
        } else {
            waitingAtTheEdgeTimer = nil
        }
    }
    
    @objc private func changeWaitingPage() {
        guard   !delegate.isEditingItems,
            let edge = waitingEdge,
            let dropCandidateCollectionView = destinationCollectionView else {
                
                initializeWaitingAtTheEdge()
                return
        }
        
        if edge == .right || edge == .left {
            changeWaitingPageHorizontal(edge: edge, collectionView: dropCandidateCollectionView)
        }
        else {
            changeWaitingPageVertical(edge: edge, collectionView: dropCandidateCollectionView)
        }
        initializeWaitingAtTheEdge()
    }
    
    private func changeWaitingPageHorizontal(edge: UIRectEdge, collectionView: UICollectionView) {
        var offsetDiff = collectionView.frame.size.width
        if offsetDiff > delegate.mainView.frame.size.width {
           offsetDiff = offsetDiff * 2 / 3
        }
        offsetDiff = edge == .right ? offsetDiff : -offsetDiff

        var offset = collectionView.contentOffset.x + offsetDiff
        if offset < 0 {
            offset = 0
        }
        if offset > (collectionView.contentSize.width - offsetDiff) {
            offset = collectionView.contentSize.width - offsetDiff
        }
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
    private func changeWaitingPageVertical(edge: UIRectEdge, collectionView: UICollectionView) {
        var offsetDiff = collectionView.frame.size.height
        offsetDiff = edge == .bottom ? offsetDiff : -offsetDiff

        var offset = collectionView.contentOffset.y + offsetDiff
        if offset < 0 {
            offset = 0
        }
        if offset > (collectionView.contentSize.height - offsetDiff) {
            offset = collectionView.contentSize.height - offsetDiff
        }
        collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
}

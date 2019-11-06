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
    var isEditing: Bool { get }
    
    func transactionSource(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionSource?
    func animateTransactionFinished(cell: UICollectionViewCell?)
    func animateTransactionStarted(cell: UICollectionViewCell?)
    func animateTransactionDropCandidate(cell: UICollectionViewCell?)
    func animateTransactionCompleted(from fromCell: UICollectionViewCell?, to toCell: UICollectionViewCell, completed: (() -> Void)?)
    func animateTransactionCancelled(from cell: UICollectionViewCell?)
}

class TransactionController {
    
    let delegate: TransactionControllerDelegate
    
    var isTransactionStarted: Bool {
        return transactionStartedCollectionView != nil
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
    var transactionStartedLocation: CGPoint? = nil
    var transactionStartedCollectionView: UICollectionView? = nil {
        didSet {
            if transactionStartedCollectionView != oldValue {
                transactionStartedIndexPath = nil
                transactionStartedLocation = nil
            }
        }
    }
    
    var transactionStartedIndexPath: IndexPath? = nil {
        didSet {
            if transactionStartedIndexPath != oldValue {
                transactionStartedCell = nil
            }
        }
    }
    
    var transactionStartedCell: UICollectionViewCell? = nil {
        didSet {
            if transactionStartedCell != oldValue {
                delegate.animateTransactionFinished(cell: oldValue)
                delegate.animateTransactionStarted(cell: transactionStartedCell)
            }
        }
    }
    
    var dropCandidateCollectionView: UICollectionView? = nil {
        didSet {
            if dropCandidateCollectionView != oldValue {
                initializeWaitingAtTheEdge()
                dropCandidateIndexPath = nil
            }
        }
    }
    
    var dropCandidateIndexPath: IndexPath? = nil {
        didSet {
            if dropCandidateIndexPath != oldValue {
                dropCandidateCell = nil
            }
        }
    }
    
    var dropCandidateCell: UICollectionViewCell? = nil {
        didSet {
            if dropCandidateCell != oldValue {
                delegate.animateTransactionFinished(cell: oldValue)
                delegate.animateTransactionDropCandidate(cell: dropCandidateCell)
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
    
    func updateWaitingEdge(at location: CGPoint, in view: UIView) {
        waitingEdge = getWaitingEdge(at: location, in: view)
    }
    
    private func getWaitingEdge(at location: CGPoint, in view: UIView) -> UIRectEdge? {
        if location.x < 50 {
            return .left
        }
        if location.x > (view.frame.size.width - 50) {
            return .right
        }
        return nil
    }
    
    private func initializeWaitingAtTheEdge() {
        waitingAtTheEdgeTimer?.invalidate()
        if dropCandidateCollectionView != nil && waitingEdge != nil && !delegate.isEditing {
            waitingAtTheEdgeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeWaitingPage), userInfo: nil, repeats: false)
        } else {
            waitingAtTheEdgeTimer = nil
        }
    }
    
    @objc private func changeWaitingPage() {
        guard   !delegate.isEditing,
            let edge = waitingEdge,
            let dropCandidateCollectionView = dropCandidateCollectionView else {
                
                initializeWaitingAtTheEdge()
                return
        }
        var offsetDiff = dropCandidateCollectionView.frame.size.width
        if offsetDiff > delegate.mainView.frame.size.width {
           offsetDiff = offsetDiff * 2 / 3
        }
        offsetDiff = edge == .right ? offsetDiff : -offsetDiff

        var offset = dropCandidateCollectionView.contentOffset.x + offsetDiff
        if offset < 0 {
            offset = 0
        }
        if offset > (dropCandidateCollectionView.contentSize.width - offsetDiff) {
            offset = dropCandidateCollectionView.contentSize.width - offsetDiff
        }
        dropCandidateCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)

        initializeWaitingAtTheEdge()
    }
}

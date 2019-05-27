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
    
    func transactionStartable(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionStartable?
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
        
        let offsetDiff = edge == .right ? delegate.mainView.frame.size.width : -delegate.mainView.frame.size.width
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
    
    private func getWaitingEdge(at location: CGPoint, in view: UIView) -> UIRectEdge? {
        if location.x < 50 {
            return .left
        }
        if location.x > (view.frame.size.width - 50) {
            return .right
        }
        return nil
    }
        
    func updateWaitingEdge(at location: CGPoint, in view: UIView) {
        waitingEdge = getWaitingEdge(at: location, in: view)
    }
    
}



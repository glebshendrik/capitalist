//
//  TransactionsControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

typealias CollectionViewIntersection = (collectionView: UICollectionView, indexPath: IndexPath?, cell: UICollectionViewCell?)?

extension MainViewController {
    var mainView: UIView {
        return self.view
    }
    
    func transactionSource(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionSource? {
        switch collectionView {
        case incomeSourcesCollectionView:
            return viewModel.incomeSourceViewModel(at: indexPath)
        case expenseSourcesCollectionView:
            return viewModel.expenseSourceViewModel(at: indexPath)
        default:
            return nil
        }
    }
    
    private func transactionDestination(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionDestination? {
        switch collectionView {
        case expenseSourcesCollectionView:
            return viewModel.expenseSourceViewModel(at: indexPath)
        case joyExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath, basketType: .joy)
        case riskExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath, basketType: .risk)
        case safeExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath, basketType: .safe)
        default:
            return nil
        }
    }
    
    private func canStartTransaction(collectionView: UICollectionView?, indexPath: IndexPath?) -> Bool {
        guard   let collectionView = collectionView,
            let indexPath = indexPath,
            let transactionSource = transactionSource(collectionView: collectionView, indexPath: indexPath) else { return false }
        return transactionSource.isTransactionSource
    }
    
    private func canCompleteTransaction(transactionStartedCollectionView: UICollectionView?,
                                        transactionStartedIndexPath: IndexPath?,
                                        completionCandidateCollectionView: UICollectionView?,
                                        completionCandidateIndexPath: IndexPath?) -> Bool {
        guard   let transactionStartedCollectionView = transactionStartedCollectionView,
            let transactionStartedIndexPath = transactionStartedIndexPath,
            let completionCandidateCollectionView = completionCandidateCollectionView,
            let completionCandidateIndexPath = completionCandidateIndexPath else { return false }
        
        guard   let transactionSource = transactionSource(collectionView: transactionStartedCollectionView, indexPath: transactionStartedIndexPath),
            let transactionDestination = transactionDestination(collectionView: completionCandidateCollectionView, indexPath: completionCandidateIndexPath) else { return false }
        
        return transactionDestination.isTransactionDestinationFor(transactionSource: transactionSource)
    }
}

extension MainViewController {
    func animateTransactionStarted(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    func animateTransactionDropCandidate(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    func animateTransactionFinished(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func animateTransactionCompleted(from fromCell: UICollectionViewCell?, to toCell: UICollectionViewCell, completed: (() -> Void)?) {
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                self.transactionDraggingElement.center = toCell.convert(toCell.contentView.center, to: self.view)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                self.transactionDraggingElement.transform = CGAffineTransform(scaleX: 0, y: 0)
                fromCell?.transform = CGAffineTransform.identity
                toCell.transform = CGAffineTransform.identity
            })
        }, completion:{ _ in
            self.transactionDraggingElement.isHidden = true
            self.transactionDraggingElement.transform = CGAffineTransform.identity
            self.transactionController.transactionStartedCollectionView = nil
            self.transactionController.dropCandidateCollectionView = nil
            completed?()
        })
    }
    
    func animateTransactionCancelled(from cell: UICollectionViewCell?) {
        UIView.animateKeyframes(withDuration: 0.6, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                if let cell = cell {
                    self.transactionDraggingElement.center = cell.convert(cell.contentView.center, to: self.view)
                }
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.transactionDraggingElement.transform = CGAffineTransform(scaleX: 0, y: 0)
                cell?.transform = CGAffineTransform.identity
            })
        }, completion:{ _ in
            self.transactionDraggingElement.isHidden = true
            self.transactionDraggingElement.transform = CGAffineTransform.identity
            self.transactionController.transactionStartedCollectionView = nil
            self.transactionController.dropCandidateCollectionView = nil
        })
    }
}

extension MainViewController {
    func detectCollectionViewIntersection(at location: CGPoint,
                                          in view: UIView,
                                          collectionViewsPool: [UICollectionView],
                                          transformation: CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)) -> CollectionViewIntersection {
        
        guard let intersectedCollectionView = collectionViewsPool.first(where: { collectionView in
            let pointInside = view.convert(location, to: collectionView)
            return collectionView.bounds.contains(pointInside)
        }) else {
            return nil
        }
        
        let locationInCollectionView = view.convert(location, to: intersectedCollectionView).applying(transformation)
        
        guard let indexPath = intersectedCollectionView.indexPathForItem(at: locationInCollectionView) else {
            return (collectionView: intersectedCollectionView, indexPath: nil, cell: nil)
        }
        
        let cell = intersectedCollectionView.cellForItem(at: indexPath)
        
        return (collectionView: intersectedCollectionView, indexPath: indexPath, cell: cell)
    }
}

extension MainViewController {
    private func updateDraggingElement(location: CGPoint, transform: CGAffineTransform) {
        guard let transactionStartedLocation = transactionController.transactionStartedLocation else {
            transactionDraggingElement.isHidden = true
            return
        }
        if transactionDraggingElement.isHidden {
            transactionDraggingElement.isHidden = location.distance(from: transactionStartedLocation) < 3
        }
        transactionDraggingElement.center = location.applying(transform)
    }
}


extension MainViewController : TransactionControllerDelegate {
    
    @objc func didRecognizeTransactionGesture(gesture: UILongPressGestureRecognizer) {
        
        guard !isEditing else { return }
        
        let locationInView = gesture.location(in: self.view)
        let verticalTranslationTransformation = CGAffineTransform(translationX: 0, y: -30)
        
        switch gesture.state {
        case .began:
            
            let collectionViews: [UICollectionView] = [incomeSourcesCollectionView,
                                                       expenseSourcesCollectionView]
            
            let intersections = detectCollectionViewIntersection(at: locationInView,
                                                                 in: self.view,
                                                                 collectionViewsPool: collectionViews)
            
            transactionController.transactionStartedCollectionView = intersections?.collectionView
            transactionController.transactionStartedIndexPath = intersections?.indexPath
            
            guard   let cell = intersections?.cell,
                canStartTransaction(collectionView: transactionController.transactionStartedCollectionView,
                                    indexPath: transactionController.transactionStartedIndexPath) else {
                                        
                                        
                                        self.transactionController.transactionStartedCollectionView = nil
                                        transactionDraggingElement.isHidden = true
                                        return
            }
            
            transactionController.transactionStartedLocation = locationInView
            transactionController.transactionStartedCell = cell
            updateDraggingElement(location: locationInView, transform: verticalTranslationTransformation)
            switchOffScrolling(for: transactionController.transactionStartedCollectionView)
            
        case .changed:
            
            guard   let transactionStartedCollectionView = transactionController.transactionStartedCollectionView,
                let transactionStartedIndexPath = transactionController.transactionStartedIndexPath else {
                    animateTransactionFinished(cell: self.transactionController.transactionStartedCell)
                    animateTransactionFinished(cell: transactionController.dropCandidateCell)
                    return
            }
            
            switchOffScrolling(for: transactionStartedCollectionView)
            
            updateDraggingElement(location: locationInView, transform: verticalTranslationTransformation)
            
            
            let collectionViews: [UICollectionView] = [expenseSourcesCollectionView,
                                                       joyExpenseCategoriesCollectionView,
                                                       riskExpenseCategoriesCollectionView,
                                                       safeExpenseCategoriesCollectionView]
            
            let intersections = detectCollectionViewIntersection(at: locationInView,
                                                                 in: self.view,
                                                                 collectionViewsPool: collectionViews,
                                                                 transformation: verticalTranslationTransformation)
            
            
            
            
            transactionController.dropCandidateCollectionView = intersections?.collectionView
            
            transactionController.updateWaitingEdge(at: locationInView, in: self.view)
            
            if transactionController.dropCandidateCollectionView == transactionStartedCollectionView && intersections?.indexPath == transactionStartedIndexPath {
                transactionController.dropCandidateIndexPath = nil
                return
            }
            
            let canComplete = canCompleteTransaction(transactionStartedCollectionView: transactionStartedCollectionView,
                                                     transactionStartedIndexPath: transactionStartedIndexPath,
                                                     completionCandidateCollectionView: transactionController.dropCandidateCollectionView,
                                                     completionCandidateIndexPath: intersections?.indexPath)
            
            transactionController.dropCandidateIndexPath = canComplete ? intersections?.indexPath : nil
            transactionController.dropCandidateCell = canComplete ? intersections?.cell : nil
            
        default:
            guard   let transactionStartedCollectionView = transactionController.transactionStartedCollectionView,
                let transactionStartedIndexPath = transactionController.transactionStartedIndexPath else {
                    transactionDraggingElement.isHidden = true
                    
                    selectIntersectedItem(at: locationInView,
                                          in: self.view)
                    return
            }
            
            let transactionStartedCell = transactionStartedCollectionView.cellForItem(at: transactionStartedIndexPath)
            
            if  let dropCandidateCollectionView = transactionController.dropCandidateCollectionView,
                let dropCandidateIndexPath = transactionController.dropCandidateIndexPath,
                let dropCandidateCell = dropCandidateCollectionView.cellForItem(at: dropCandidateIndexPath),
                let transactionSource = transactionSource(collectionView: transactionStartedCollectionView, indexPath: transactionStartedIndexPath),
                let transactionDestination = transactionDestination(collectionView: dropCandidateCollectionView, indexPath: dropCandidateIndexPath) {
                
                animateTransactionCompleted(from: transactionStartedCell, to: dropCandidateCell, completed: {
                    self.showTransactionEditScreen(transactionSource: transactionSource, transactionDestination: transactionDestination)
                })
                
            } else {
                animateTransactionCancelled(from: transactionStartedCell)
                
                selectIntersectedItem(at: locationInView,
                                      in: self.view,
                                      with: transactionStartedCollectionView,
                                      indexPath: transactionStartedIndexPath)
            }
        }
    }
    
    private func selectIntersectedItem(at location: CGPoint,
                                       in view: UIView,
                                       with collectionView: UICollectionView? = nil,
                                       indexPath: IndexPath? = nil) {
        
        let allCollectionViews: [UICollectionView] = [incomeSourcesCollectionView,
                                                      expenseSourcesCollectionView,
                                                      joyExpenseCategoriesCollectionView,
                                                      riskExpenseCategoriesCollectionView,
                                                      safeExpenseCategoriesCollectionView]
        
        
        let pool = collectionView == nil ? allCollectionViews : [collectionView!]
        
        let intersections = detectCollectionViewIntersection(at: location,
                                                             in: view,
                                                             collectionViewsPool: pool)
        
        if  let intersectedCollectionView = intersections?.collectionView,
            let intersectedIndexPath = intersections?.indexPath {
            
            if (collectionView == nil || intersectedCollectionView == collectionView) && (indexPath == nil || intersectedIndexPath == indexPath) {
                self.collectionView(intersectedCollectionView, didSelectItemAt: intersectedIndexPath)
            }
        }
    }
}

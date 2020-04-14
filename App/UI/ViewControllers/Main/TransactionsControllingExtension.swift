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
        case expenseSourcesCollectionView:
            return viewModel.expenseSourceViewModel(at: indexPath)
        case riskActivesCollectionView:
            return viewModel.activeViewModel(at: indexPath, basketType: .risk)
        case safeActivesCollectionView:
            return viewModel.activeViewModel(at: indexPath, basketType: .safe)
        default:
            return nil
        }
    }
    
    private func transactionDestination(collectionView: UICollectionView, indexPath: IndexPath) -> TransactionDestination? {
        switch collectionView {
        case expenseSourcesCollectionView:
            return viewModel.expenseSourceViewModel(at: indexPath)
        case joyExpenseCategoriesCollectionView:
            return viewModel.expenseCategoryViewModel(at: indexPath)
        case riskActivesCollectionView:
            return viewModel.activeViewModel(at: indexPath, basketType: .risk)
        case safeActivesCollectionView:
            return viewModel.activeViewModel(at: indexPath, basketType: .safe)
        default:
            return nil
        }
    }
    
    private func isTransactionSource(collectionView: UICollectionView?, indexPath: IndexPath?) -> Bool {
        guard   let collectionView = collectionView,
                let indexPath = indexPath,
                let transactionSource = transactionSource(collectionView: collectionView, indexPath: indexPath) else { return false }
        
        return transactionSource.isTransactionSource
    }
    
    private func canCompleteTransaction(sourceCollectionView: UICollectionView?,
                                        sourceIndexPath: IndexPath?,
                                        destinationCollectionView: UICollectionView?,
                                        destinationIndexPath: IndexPath?) -> Bool {
        guard   let sourceCollectionView = sourceCollectionView,
                let sourceIndexPath = sourceIndexPath,
                let destinationCollectionView = destinationCollectionView,
                let destinationIndexPath = destinationIndexPath,
                let transactionSource = transactionSource(collectionView: sourceCollectionView,
                                                          indexPath: sourceIndexPath),
                let transactionDestination = transactionDestination(collectionView: destinationCollectionView,
                                                                    indexPath: destinationIndexPath) else { return false }
        
        return transactionDestination.isTransactionDestinationFor(transactionSource: transactionSource)
    }
}

extension MainViewController {
    
    func didSetSource(cell: UICollectionViewCell?, animated: Bool) {
        if isSelecting {
            cell?.set(selected: true, animated: animated)
            updateAdviserTip()
        }
        else {
            cell?.set(selected: true, animated: animated)
//            cell?.scaleDown(animated: animated)
        }
    }

    func didSetDestination(cell: UICollectionViewCell?, animated: Bool) {
        if isSelecting {
            cell?.set(selected: true, animated: animated)
            updateAdviserTip()
        }
        else {
            cell?.set(selected: true, animated: animated)
//            cell?.scaleUp(animated: animated)
        }
    }

    func didSetNormal(cell: UICollectionViewCell?, animated: Bool) {
        if isSelecting {
            cell?.set(selected: false, animated: animated)
        }
        else {
            cell?.set(selected: false, animated: animated)
//            cell?.unscale(animated: animated)
        }
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
            self.completeTransactionInteraction()
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
            self.completeTransactionInteraction()
        })
    }
    
    func completeTransactionInteraction() {
        transactionDraggingElement.isHidden = true
        transactionDraggingElement.transform = CGAffineTransform.identity
        transactionController.sourceCollectionView = nil
        transactionController.sourceCell = nil
        transactionController.destinationCollectionView = nil
        transactionController.destinationCell = nil
        adviserTip?.dismiss()
        viewModel.resetTransactionables()
    }
}

extension MainViewController {
    func detectCollectionViewIntersection(at location: CGPoint,
                                          in view: UIView,
                                          collectionViewsPool: [UICollectionView],
                                          transformation: CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)) -> CollectionViewIntersection {
        
        let collectionViewFromPool = collectionViewsPool.first { collectionView in
            let pointInside = view.convert(location, to: collectionView)
            return collectionView.bounds.contains(pointInside)
        }
        
        guard let intersectedCollectionView = collectionViewFromPool else { return nil }
        
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
        guard let sourceLocation = transactionController.sourceLocation else {
            transactionDraggingElement.isHidden = true
            return
        }
        if transactionDraggingElement.isHidden {
            transactionDraggingElement.isHidden = location.distance(from: sourceLocation) < 3
        }
        transactionDraggingElement.center = location.applying(transform)
    }
}


extension MainViewController : TransactionControllerDelegate {
    var isSelecting: Bool {
        return viewModel.selecting
    }
    
    var isEditingItems: Bool {
        return viewModel.editing
    }
    
    func sourceCollectionViews() -> [UICollectionView] {
        return [expenseSourcesCollectionView,
                riskActivesCollectionView,
                safeActivesCollectionView]
    }
    
    func destinationCollectionViews() -> [UICollectionView] {
        return [expenseSourcesCollectionView,
                joyExpenseCategoriesCollectionView,
                riskActivesCollectionView,
                safeActivesCollectionView]
    }
    
    func allCollectionViews() -> [UICollectionView] {
        return [expenseSourcesCollectionView,
                joyExpenseCategoriesCollectionView,
                riskActivesCollectionView,
                safeActivesCollectionView]
    }
    
    func select(_ transactionable: Transactionable, collectionView: UICollectionView, indexPath: IndexPath) {
        let wasSelected = transactionable.isSelected
        viewModel.select(transactionable)
        if wasSelected != transactionable.isSelected {            
            updateTotalUI(animated: true)
            let cell = (collectionView.cellForItem(at: indexPath) as? TransactionableCell)
            
            if viewModel.selectedSource == nil {
                transactionController.sourceCell = nil
            }
            else if transactionable.id == viewModel.selectedSource?.id && transactionable.type == viewModel.selectedSource?.type  {
                transactionController.sourceCell = cell
            }
            
            if viewModel.selectedDestination == nil {
                transactionController.destinationCell = nil
            }
            else if transactionable.id == viewModel.selectedDestination?.id && transactionable.type == viewModel.selectedDestination?.type  {
                transactionController.destinationCell = cell
            }
            
            if let source = viewModel.selectedSource as? TransactionSource,
                let destination = viewModel.selectedDestination as? TransactionDestination {
                showTransactionEditScreen(transactionSource: source, transactionDestination: destination)
            }
        }
    }
    
    func didSetTransactionables(source: TransactionSource, destination: TransactionDestination) {
        showTransactionEditScreen(transactionSource: source, transactionDestination: destination)
        setSelecting(false, animated: true)
        completeTransactionInteraction()
    }
    
    @objc func didRecognizeTransactionGesture(gesture: UILongPressGestureRecognizer) {
        
        guard !isEditingItems && !isSelecting else { return }
        
        let locationInView = gesture.location(in: self.view)
                    
        let verticalTranslationTransformation = CGAffineTransform(translationX: 0, y: -30)
        
        switch gesture.state {
        case .began:
            transactionController.startedLocation = locationInView
            
            let intersection = detectCollectionViewIntersection(at: locationInView,
                                                                in: self.view,
                                                                collectionViewsPool: sourceCollectionViews())
            
            transactionController.sourceCollectionView = intersection?.collectionView
            transactionController.sourceIndexPath = intersection?.indexPath
            
            guard   let cell = intersection?.cell,
                    isTransactionSource(collectionView: transactionController.sourceCollectionView,
                                        indexPath: transactionController.sourceIndexPath) else {
                                        
                completeTransactionInteraction()
                return
            }
            
            transactionController.sourceLocation = locationInView
            transactionController.sourceCell = cell
            updateDraggingElement(location: locationInView, transform: verticalTranslationTransformation)
            switchOffScrolling(for: transactionController.sourceCollectionView)
            
        case .changed:
            transactionController.currentLocation = locationInView
            guard   let sourceCollectionView = transactionController.sourceCollectionView,
                    let sourceIndexPath = transactionController.sourceIndexPath else {
                    
                didSetNormal(cell: transactionController.sourceCell, animated: true)
                didSetNormal(cell: transactionController.destinationCell, animated: true)
                return
            }
            
            switchOffScrolling(for: sourceCollectionView)
            updateDraggingElement(location: locationInView, transform: verticalTranslationTransformation)
                        
            let intersection = detectCollectionViewIntersection(at: locationInView,
                                                                 in: self.view,
                                                                 collectionViewsPool: destinationCollectionViews(),
                                                                 transformation: verticalTranslationTransformation)
            
            
            
            
            transactionController.destinationCollectionView = intersection?.collectionView
            
            let locationInCollectionView = gesture.location(in: intersection?.collectionView.superview)
            let direction = scrollDirection(of: transactionController.destinationCollectionView)
            
            transactionController.updateWaitingEdge(at: locationInView,
                                                    in: self.view,
                                                    locationInCollectionView: locationInCollectionView,
                                                    direction: direction)
            
            if transactionController.destinationCollectionView == sourceCollectionView && intersection?.indexPath == sourceIndexPath {
                transactionController.destinationIndexPath = nil
                return
            }
            
            let canComplete = canCompleteTransaction(sourceCollectionView: sourceCollectionView,
                                                     sourceIndexPath: sourceIndexPath,
                                                     destinationCollectionView: transactionController.destinationCollectionView,
                                                     destinationIndexPath: intersection?.indexPath)
            
            transactionController.destinationIndexPath = canComplete ? intersection?.indexPath : nil
            transactionController.destinationCell = canComplete ? intersection?.cell : nil
            
        default:
            guard   let sourceCollectionView = transactionController.sourceCollectionView,
                    let sourceIndexPath = transactionController.sourceIndexPath else {
                    
                    selectIntersectedItem(at: locationInView, in: self.view)
                    completeTransactionInteraction()
                    return
            }
            
            let sourceCell = sourceCollectionView.cellForItem(at: sourceIndexPath)
            
            if  let destinationCollectionView = transactionController.destinationCollectionView,
                let destinationIndexPath = transactionController.destinationIndexPath,
                let destinationCell = destinationCollectionView.cellForItem(at: destinationIndexPath),
                let transactionSource = transactionSource(collectionView: sourceCollectionView,
                                                          indexPath: sourceIndexPath),
                let transactionDestination = transactionDestination(collectionView: destinationCollectionView,
                                                                    indexPath: destinationIndexPath) {
                
                animateTransactionCompleted(from: sourceCell, to: destinationCell, completed: {
                    self.showTransactionEditScreen(transactionSource: transactionSource,
                                                   transactionDestination: transactionDestination)
                })
                
            }
            else {
                
                animateTransactionCancelled(from: sourceCell)
                if transactionDraggingElement.isHidden {
                    selectIntersectedItem(at: locationInView,
                                          in: self.view,
                                          with: sourceCollectionView,
                                          indexPath: sourceIndexPath)

                }
            }
        }
    }
    
    private func allCollectionViews(or collectionView: UICollectionView? = nil) -> [UICollectionView] {
        guard let collectionView = collectionView else { return allCollectionViews() }
        return [collectionView]
    }
    
    private func selectIntersectedItem(at location: CGPoint,
                                       in view: UIView,
                                       with collectionView: UICollectionView? = nil,
                                       indexPath: IndexPath? = nil) {
        
        guard   let startedLocation = transactionController.startedLocation,
                !transactionController.wentFarFromStart else { return }
        
        let pool = allCollectionViews(or: collectionView)
        let intersection = detectCollectionViewIntersection(at: location,
                                                            in: view,
                                                            collectionViewsPool: pool)
        let startedIntersection = detectCollectionViewIntersection(at: startedLocation,
                                                                   in: view,
                                                                   collectionViewsPool: pool)
        if  let intersectedCollectionView = intersection?.collectionView,
            let intersectedIndexPath = intersection?.indexPath,
            intersectedCollectionView == startedIntersection?.collectionView,
            intersectedIndexPath == startedIntersection?.indexPath {
            
            if (collectionView == nil || intersectedCollectionView == collectionView) && (indexPath == nil || intersectedIndexPath == indexPath) {                
                self.collectionView(intersectedCollectionView, didSelectItemAt: intersectedIndexPath)
            }
        }
    }
}

//
//  ActionsControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 05.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import EasyTipView
typealias TutorialPayload = (point: UIFlowPoint, message: String, anchor: UIAppearance,  position: EasyTipView.ArrowPosition, offset: CGPoint?, inset: CGPoint?)

extension MainViewController {
    func tapMainButton() {
        if isEditingItems {
            setEditingItems(false, animated: true)
        }
        else {
//            setSelecting(!isSelecting, animated: true)
        }
    }
    
    func setEditingItems(_ editing: Bool, animated: Bool) {
        guard editing != isEditingItems else { return }
                
        viewModel.set(editing: editing)
        setVisibleCells(editing: editing)
        updateCollectionViews()
        updateLongPressureRecognizers()
        updateTotalUI(animated: true)        
        updateMainButtonUI()
        view.haptic()
    }
    
//    func setSelecting(_ selecting: Bool, animated: Bool) {
//        guard selecting != isSelecting else { return }
//        
//        viewModel.set(selecting: selecting)
//        updateMainButtonUI()
//        updateTotalUI(animated: true)
//        if isSelecting {
////            updateAdviserTip()
//        }
//        else {
//            completeTransactionInteraction()            
//        }
//        updateCollectionViews()
//        view.haptic()
//    }
    
    func updateMainButtonUI() {
        let isCancelState = isEditingItems
        plusMenu.isHidden = isCancelState
        plusMenu.isUserInteractionEnabled = !isCancelState
        let transform = isCancelState ? CGAffineTransform(rotationAngle: CGFloat(3 * Double.pi / 4)) : .identity
        let color = isCancelState ? UIColor.by(ColorAsset.red1) : UIColor.by(.blue1)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.mainButton.transform = transform
                self.mainButton.backgroundColor = color
            })
    }
}

extension MainViewController : EasyTipViewDelegate {
    var tutorials: [TutorialPayload] {
        return [TutorialPayload(point: .incomeSourcesTutorial,
                                message: NSLocalizedString("Добавляй источник дохода через меню или при создании транзакции дохода", comment: ""),
                                anchor: menuTutorialAnchor,
                                position: .top,
                                offset: CGPoint(x: 15, y: 0),
                                inset: nil),
                TutorialPayload(point: .debtsAndCreditsTutorial,
                                message: NSLocalizedString("Удобное управление долгами, займами и кредитами через меню", comment: ""),
                                anchor: menuTutorialAnchor,
                                position: .top,
                                offset: CGPoint(x: 15, y: 0),
                                inset: nil),
                TutorialPayload(point: .settingsTutorial,
                                message: NSLocalizedString("Регулируй скорость перетягивания монетки в настройках", comment: ""),
                                anchor: menuTutorialAnchor,
                                position: .top,
                                offset: CGPoint(x: 15, y: 0),
                                inset: nil)]
    }
    
    func show(_ tutorials: [TutorialPayload]) {
        guard let tutorial = tutorials.first(where: { !UIFlowManager.reached(point: $0.point) }) else {
            showAdviserTip()
            return
        }
        
        setMainOverlay(hidden: false)
        tutorialTip = tip(tutorial.message,
                          position: tutorial.position,
                          offset: tutorial.offset,
                          inset: tutorial.inset,
                          for: tutorial.anchor,
                          within: view,
                          delegate: self)
        UIFlowManager.set(point: tutorial.point, reached: true)
    }
    
    private func showTransactionCreationInfoViewController() {
        slideUp(factory.transactionCreationInfoViewController(),
                toBottomOf: expenseSourcesCollectionView,
                shouldDim: true)
    }
    
    func showAdviserTip() {
        adviserTip = tip(NSLocalizedString("Скоро здесь будет финансовый советник", comment: "Скоро здесь будет финансовый советник"),
                         position: .left,
                         offset: nil,
                         inset: CGPoint(x: 15, y: 2),
                         for: titleView.tipAnchor,
                         within: titleView,
                         delegate: self)        
    }
        
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        if tipView == tutorialTip {
            setMainOverlay(hidden: true)
            show(tutorials)
        }
    }
}

extension MainViewController {
    func setVisibleCells(editing: Bool) {
        let cells = expenseSourcesCollectionView.visibleCells + joyExpenseCategoriesCollectionView.visibleCells + riskActivesCollectionView.visibleCells + safeActivesCollectionView.visibleCells
        
        for cell in cells {
            cell.set(editing: editing)
        }
    }
}

extension MainViewController {
    @objc func appMovedToForeground() {
        checkAppUpdateNeeded()
        setVisibleCells(editing: isEditingItems)        
    }
}

extension MainViewController {
    @objc func finantialDataInvalidated() {
        loadData()
    }
}

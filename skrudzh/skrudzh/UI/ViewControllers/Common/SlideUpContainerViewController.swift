//
//  IncomeSourceSelectViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class SlideUpContainerViewController : UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var verticalOffsetConstraint: NSLayoutConstraint!
    weak var viewControllerToAdd: UIViewController? = nil
    
    var isPresenting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.roundTopCorners(radius: 8.0)
    }
    
    private func addChild() {
        guard let viewController = viewControllerToAdd else { return }
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
            ])
        
        viewController.didMove(toParent: self)
    }
    
    private func setupUI() {
        configureBackground()
        addChild()
    }
    
    private func configureBackground() {
        backgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
    }
    
    @objc func didTapBackgroundView(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension SlideUpContainerViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            backgroundView.alpha = 0
            verticalOffsetConstraint = verticalOffsetConstraint.setMultiplier(multiplier: 1)
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 1
                self.verticalOffsetConstraint = self.verticalOffsetConstraint.setMultiplier(multiplier: 0.35)
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 0
                self.verticalOffsetConstraint = self.verticalOffsetConstraint.setMultiplier(multiplier: 1)
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}

extension UIViewController {
    func slideUp(viewController: UIViewController) {
        
        if let slideUpContainerViewController = UIStoryboard.main?.instantiateViewController(withIdentifier: Infrastructure.ViewController.SlideUpContainerViewController.identifier) as? SlideUpContainerViewController {
            
            slideUpContainerViewController.modalPresentationStyle = .custom
            slideUpContainerViewController.transitioningDelegate = slideUpContainerViewController
            slideUpContainerViewController.viewControllerToAdd = viewController
            
            present(slideUpContainerViewController, animated: true)
            
        }
    }
}

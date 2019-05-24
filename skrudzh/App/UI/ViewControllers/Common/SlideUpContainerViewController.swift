//
//  IncomeSourceSelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class SlideUpContainerViewController : UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var verticalOffsetConstraint: NSLayoutConstraint!
    weak var viewControllerToAdd: UIViewController? = nil
    
    private var isPresenting = false
    private var originalPosition: CGPoint = CGPoint.zero
    
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
        configureContentView()
        addChild()
    }
    
    private func configureBackground() {
        backgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
    }
    
    private func configureContentView() {
        contentView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanContentView(_:))))
    }
    
    @objc func didTapBackgroundView(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    @objc func didPanContentView(_ panGesture: UIPanGestureRecognizer) {
        let locationInView = panGesture.location(in: view)
        
        switch panGesture.state {
        case .began:
            originalPosition = locationInView
        case .changed:
            if locationInView.y > originalPosition.y {
                verticalOffsetConstraint = verticalOffsetConstraint.setMultiplier(multiplier: (0.35 * view.frame.height + (locationInView.y - originalPosition.y)) / view.frame.height)
                view.layoutIfNeeded()
            }
        case .ended:
            let velocity = panGesture.velocity(in: contentView)
            
            if velocity.y >= 500 || verticalOffsetConstraint.multiplier >= 0.5 {
                animateSlideDown {
                    self.dismiss(animated: false, completion: nil)
                }
                
            } else {
                animateSlideUp()
            }
        case .cancelled, .failed:
            animateSlideUp()
        default:
           break
        }
    }
    
    private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    private func animateSlideDown(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.backgroundView.alpha = 0
            self.verticalOffsetConstraint = self.verticalOffsetConstraint.setMultiplier(multiplier: 1)
            self.view.layoutIfNeeded()
        }, completion: { (isCompleted) in
            completion?()
        })
    }
    
    private func animateSlideUp(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.backgroundView.alpha = 1
            self.verticalOffsetConstraint = self.verticalOffsetConstraint.setMultiplier(multiplier: 0.35)
            self.view.layoutIfNeeded()
        }, completion: { (isCompleted) in
            completion?()
        })
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
            view.layoutIfNeeded()
            animateSlideUp {
                transitionContext.completeTransition(true)
            }
            
        } else {
            animateSlideDown {
                transitionContext.completeTransition(true)
            }
        }
    }
}

extension UIViewController {
    func slideUp(viewController: UIViewController) {
        
        if let slideUpContainerViewController = UIStoryboard(name: Infrastructure.Storyboard.Common.name, bundle: Bundle.main).instantiateViewController(withIdentifier: Infrastructure.ViewController.SlideUpContainerViewController.identifier) as? SlideUpContainerViewController {
            
            slideUpContainerViewController.modalPresentationStyle = .custom
            slideUpContainerViewController.transitioningDelegate = slideUpContainerViewController
            slideUpContainerViewController.viewControllerToAdd = viewController
            
            present(slideUpContainerViewController, animated: true)
            
        }
    }
}

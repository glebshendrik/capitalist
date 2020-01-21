//
//  TransactionCommentViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import ALTextInputBar

protocol CommentViewControllerDelegate {
    func didSave(comment: String?)
}

protocol CommentViewControllerInputProtocol {
    func set(comment: String?, placeholder: String)
    func set(delegate: CommentViewControllerDelegate?)
}

class CommentViewController : UIViewController, CommentViewControllerInputProtocol {
    
    let textInputBar = ALTextInputBar()
    
    private var delegate: CommentViewControllerDelegate? = nil
    
    override var inputAccessoryView: UIView? {
        get {
            return textInputBar
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    var isPresenting = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        focusInputView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textInputBar.roundTopCorners(radius: 8.0)
    }
    
    func set(delegate: CommentViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(comment: String?, placeholder: String) {
        textInputBar.textView.text = comment
        textInputBar.textView.placeholder = placeholder
    }
    
    private func setupUI() {
        configureBackground()
        configureInputBar()
    }
    
    private func configureBackground() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        
        backgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
    }
    
    private func configureInputBar() {
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        rightButton.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        rightButton.setImage(UIImage(named: "save-icon"), for: .normal)
        
        textInputBar.showTextViewBorder = true
        textInputBar.rightView = rightButton
        textInputBar.textViewCornerRadius = 16
        textInputBar.textViewBackgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1, alpha: 1)
        textInputBar.textViewBorderWidth = 0
        textInputBar.textView.font = UIFont(name: "Roboto-Medium", size: 18)
        textInputBar.textView.textColor = UIColor.by(.white100)
        
        textInputBar.alwaysShowRightButton = true
        textInputBar.defaultHeight = 64
        textInputBar.textViewBorderPadding = UIEdgeInsets(horizontal: 20, vertical: 6)
        textInputBar.horizontalPadding = 16
        textInputBar.horizontalSpacing = 4
        textInputBar.backgroundColor = UIColor.by(.black2)
        textInputBar.roundTopCorners(radius: 8.0)
    }
    
    private func focusInputView() {
        textInputBar.textView.becomeFirstResponder()
    }
    
    @objc func didTapBackgroundView(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    @objc func didTapCloseButton(_ sender: UIButton) {
        close()
    }
    
    @objc func didTapSaveButton(_ sender: UIButton) {
        delegate?.didSave(comment: textInputBar.text)
        close()
    }
    
    private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension CommentViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            backgroundView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 1
            }, completion: { (finished) in
                
            })
            transitionContext.completeTransition(true)
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 0
                self.textInputBar.textView.resignFirstResponder()
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}

//
//  OnboardingViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class OnboardingViewController : UIViewController, OnboardingPagesViewControllerDelegate, UIFactoryDependantProtocol {
    var factory: UIFactoryProtocol!
    @IBOutlet var button: HighlightButton!
    @IBOutlet weak var loginButton: UIButton!
    var pagesController: OnboardingPagesViewController!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmbedded",
            let viewController = segue.destination as? OnboardingPagesViewController {
            pagesController = viewController
            pagesController.onboardingDelegate = self
        }
    }
    
    func setupUI() {
        pageControl.numberOfPages = pagesController.numberOfPages
        if let font = UIFont(name: "Roboto-Regular", size: 14) {
            let attributedTitle = NSMutableAttributedString(string: NSLocalizedString("Есть аккаунт?", comment: "Есть аккаунт?"), attributes: [.font: font, .foregroundColor: UIColor.by(.white64)])
            attributedTitle.append(NSAttributedString(string: NSLocalizedString(" Войдите", comment: " Войдите"), attributes: [.font: font, .foregroundColor: UIColor.by(.white100)]))
            loginButton.setAttributedTitle(attributedTitle, for: .normal)
        }
        
        let pageControlBottomMargin = view.frame.height * 0.02
        let loginButtonBottomMargin = view.frame.height * 0.02
        
        loginButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-loginButtonBottomMargin)
        }
        
        button.snp.makeConstraints { (make) in
            make.bottom.equalTo(loginButton.snp.top).offset(-loginButtonBottomMargin)
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(button.snp.top).offset(-pageControlBottomMargin)
        }
        
    }
    
    func updateUI() {
        pageControl.currentPage = pagesController.currentPageIndex
    }
    
    func didPresentPage() {
        updateUI()
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        pagesController.showNextPage()
    }
    
    @IBAction func didTapSkipButton(_ sender: Any) {
        pagesController.finishOnboarding()
    }
    
    @IBAction func didTapJoinButton(_ sender: Any) {
        modal(factory.loginNavigationController())
    }
}

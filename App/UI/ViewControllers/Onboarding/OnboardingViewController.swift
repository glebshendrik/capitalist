//
//  OnboardingViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class OnboardingViewController : UIViewController, OnboardingPagesViewControllerDelegate, UIFactoryDependantProtocol {
    var factory: UIFactoryProtocol!
    @IBOutlet var button: HighlightButton!
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
    }
    
    func updateUI() {
        button.setTitle(pagesController.isLastPageShown
            ? NSLocalizedString("Отлично, начать!", comment: "Отлично, начать!")
            : NSLocalizedString("Далее", comment: "Далее"),
                        for: .normal)
        button.backgroundColor = pagesController.isLastPageShown ? UIColor.by(.blue1) : UIColor.clear
        button.backgroundColorForNormal = pagesController.isLastPageShown ? UIColor.by(.blue1) : UIColor.clear
        button.backgroundColorForHighlighted = pagesController.isLastPageShown ? UIColor.by(.white40) : UIColor.clear
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

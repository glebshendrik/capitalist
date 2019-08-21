//
//  OnboardingViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class OnboardingViewController : UIViewController, OnboardingPagesViewControllerDelegate {
    @IBOutlet var button: HighlightButton!
    var pagesController: OnboardingPagesViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmbedded",
            let viewController = segue.destination as? OnboardingPagesViewController {
            pagesController = viewController
            pagesController.onboardingDelegate = self
        }
    }
    
    func updateUI() {
        button.setTitle(pagesController.isLastPageShown ? "Начать" : "Продолжить", for: .normal)
    }
    
    func didPresentPage() {
        updateUI()
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        pagesController.showNextPage()
    }
}

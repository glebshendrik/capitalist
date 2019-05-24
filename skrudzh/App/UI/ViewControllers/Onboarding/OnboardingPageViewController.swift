//
//  OnboardingPageViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class OnboardingPageViewController : UIViewController {
    var onboardingViewController: OnboardingViewController? {
        return parent as? OnboardingViewController
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        goNext()
    }
    
    @IBAction func didTapStartButton(_ sender: Any) {
        finishOnboarding()
    }
    
    private func goNext() {
        onboardingViewController?.showNext(after: self)
    }
    
    private func finishOnboarding() {
        onboardingViewController?.finishOnboarding()
    }
}

class OnboardingPage5ViewController : OnboardingPageViewController {
    @IBOutlet weak var informationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInformationLabel()
    }
    
    private func setupInformationLabel() {
        let string = "Из этой корзины вы инвестируете в бизнес, акции, криптовалюту, форекс и другие инструменты с годовой доходностью от 15 процентов." as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String,
                                                         attributes: [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 14) as Any])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 14)]
        
        
        attributedString.addAttributes(boldFontAttribute as [NSAttributedString.Key : Any], range: string.range(of: "с годовой доходностью от 15 процентов"))
        
        informationLabel.attributedText = attributedString
    }
}

class OnboardingPage6ViewController : OnboardingPageViewController {
    @IBOutlet weak var informationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInformationLabel()
    }
    
    private func setupInformationLabel() {
        let string = "Реальная инфляция в России 7–8%. Чтобы сохранить деньги, их нужно инвестировать под 10-15% годовых." as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String,
                                                         attributes: [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 14) as Any])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 14)]
        
        
        attributedString.addAttributes(boldFontAttribute as [NSAttributedString.Key : Any], range: string.range(of: "7–8%"))
        attributedString.addAttributes(boldFontAttribute as [NSAttributedString.Key : Any], range: string.range(of: "под 10-15% годовых"))
        
        informationLabel.attributedText = attributedString
    }
}

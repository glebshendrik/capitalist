//
//  AppInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import AttributedTextView
import StoreKit
import MessageUI

class AppInfoViewController : UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var accountCoordinator: AccountCoordinatorProtocol!
    
    var privacyURLString: String {
        return NSLocalizedString("privacy policy url", comment: "privacy policy url")
    }
    
    var termsURLString: String {
        return NSLocalizedString("terms of service url", comment: "terms of service url")
    }
    
    var descriptionText: NSAttributedString {
        let text = NSLocalizedString("App description text", comment: "")
        return text
            .color(UIColor.by(.white64))
            .fontName("Roboto-Light").size(16)
            .paragraphLineHeightMultiple(1.28)
            .kern(0.32)
            .paragraphApplyStyling
            .attributedText
    }
    
    var whatsAppNumber: String {
        return "79956585967"
    }
    
    var telegramUsername: String {
        return "threebaskets"
    }
    
    var contactEmail: String {
        return "help@threebaskets.net"
    }
    
    var instagramUsername: String {
        return "threebasketsapp"
    }
    
    var defaultMessage: String {
        guard let userId = accountCoordinator.currentSession?.userId else { return "" }
        return "My ID: \(userId)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        setupNavigationBarAppearance()
        setupNavigationBar()
        setupAppVersion()
        setupAppDescription()
    }
    
    func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("О приложении", comment: "")
    }
    
    func setupAppDescription() {
        descriptionLabel.attributedText = descriptionText
    }
    
    func setupAppVersion() {
        guard let version = UIApplication.shared.version else {
            versionLabel.text = ""
            return
        }
        let versionText = NSLocalizedString("Версия: ", comment: "")
        versionLabel.text = "\(versionText)\(version)"
    }
    
    @IBAction func didTapRatingButton(_ sender: Any) {
        open(url: "itms-apps://itunes.apple.com/app/id1457533341?action=write-review")
    }
        
    @IBAction func didTapTermsOfUseButton(_ sender: Any) {
        show(url: termsURLString)
    }
    
    @IBAction func didTapPrivacyPolicyButton(_ sender: Any) {
        show(url: privacyURLString)
    }
    
    @IBAction func didTapTelegramButton(_ sender: Any) {
        open(url: "tg://resolve?domain=\(telegramUsername)")
    }
    
    @IBAction func didTapWhatsAppButton(_ sender: Any) {
        open(url: "whatsapp://send?phone=\(whatsAppNumber)&text=\(defaultMessage)")
    }
    
    @IBAction func didTapInstagramButton(_ sender: Any) {
        open(url: "instagram://user?username=\(instagramUsername)")
    }
    
    @IBAction func didTapEmailButton(_ sender: Any) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        composeVC.setToRecipients([contactEmail])
        composeVC.setSubject("Three Baskets Feedback")
        composeVC.setMessageBody(defaultMessage, isHTML: false)

        modal(composeVC)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

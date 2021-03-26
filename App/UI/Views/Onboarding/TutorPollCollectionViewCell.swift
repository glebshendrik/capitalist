//
//  TutorPollCollectionViewCell.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 23.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit

class TutorPollCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var bottomConstraintStack: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    var delegate: WelcomePollSlideProtocol!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    func customize() {
        let halfHeight = self.frame.height / 2
        bottomConstraintStack.constant = halfHeight - contentStack.frame.height / 2
    }
}


//
//  WelcomeCollectionViewCell.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 23.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit

protocol PlayVideoCellProtocol {
    func playVideoButtonDidSelect()
}

protocol WelcomePollSlideProtocol {
    func next()
    func back()
}

class WelcomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var placeholderVideo: UIImageView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var delegate: PlayVideoCellProtocol!
    var delegatePoll: WelcomePollSlideProtocol!
    
    @IBAction func onTapPlayVideo(_ sender: UIButton) {
        self.delegate.playVideoButtonDidSelect()
    }
    
}

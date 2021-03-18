//
//  LayoutElementOnboarding.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 18.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class LayoutElementOnboarding: UIView {

    override func draw(_ rect: CGRect) {
        let images = self.subviews.filter{$0 is UIImageView}
        let labels = self.subviews.filter{$0 is UILabel}
        
        let isSe = frame.height < 667
        let marginImage = isSe ? frame.height*0.12 : frame.height*0.14
        let marginLabel = isSe ? 10 : frame.height*0.75
        
        images[0].snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(marginImage)
        }
        
        labels[0].snp.makeConstraints { (make) in
            make.top.equalTo(images[0].snp.bottom).offset(marginLabel)
        }
    }
}

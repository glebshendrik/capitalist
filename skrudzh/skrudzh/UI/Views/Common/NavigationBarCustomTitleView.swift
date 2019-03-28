//
//  NavigationBarCustomTitleView.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class NavigationBarCustomTitleView : UIView {
    @IBOutlet var contentView: UIView!
    
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

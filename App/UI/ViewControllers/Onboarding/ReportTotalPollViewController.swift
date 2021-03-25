//
//  ReportTotalPollViewController.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 25.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit

class ReportTotalPollViewController: UIViewController {

    @IBOutlet weak var saleLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var capitalistCaptionLabel: UILabel!
    @IBOutlet weak var yearsWithCapitalistLabel: UILabel!
    @IBOutlet weak var capitalWithCapitalistLabel: UILabel!
    
    var viewModel: ReportTotalPollViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    private func setupUI() {
        saleLabel.text = saleLabel.text?.uppercased()
        saleLabel.backgroundColor = UIColor.by(.solitude)
        saleLabel.cornerRadius = 14
        saleLabel.snp.makeConstraints { (make) in
            make.width.equalTo(saleLabel.frame.width + 40)
        }
        
        capitalistCaptionLabel.text = capitalistCaptionLabel.text?.uppercased()
        capitalistCaptionLabel.backgroundColor = UIColor.by(.blue1)
        capitalistCaptionLabel.cornerRadius = 14
        capitalistCaptionLabel.snp.makeConstraints { (make) in
            make.width.equalTo(capitalistCaptionLabel.frame.width + 80)
        }
    }

    
    @IBAction func didTapGetItButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

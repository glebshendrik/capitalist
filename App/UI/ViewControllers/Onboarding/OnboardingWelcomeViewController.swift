//
//  OnboardingWelcomeViewController.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 19.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit
import AVKit
import SnapKit
import SwifterSwift

class OnboardingWelcomeViewController: UIViewController, UIFactoryDependantProtocol, ApplicationRouterDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pollCollection: UICollectionView!
    var viewModel: WelcomePollViewModel!
    
    private var oldCell: UICollectionViewCell?
    
    var factory: UIFactoryProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupWelcomePollCollectionView()
    }
    
    private func setupWelcomePollCollectionView() {
        pollCollection.delegate = self
        pollCollection.dataSource = self
    }
    
    
    @IBAction func onTapClose(_ sender: UIButton) {
        
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        next()
    }
    
    @IBAction func onTapBackButton(_ sender: UIButton) {
        back()
    }
}

extension OnboardingWelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPollQuestions
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = viewModel.dataCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.type.rawValue, for: indexPath)
        
        switch cell {
        case let titleCell as WelcomeCollectionViewCell:
            configure(titleCell, data: data)
        case let tutorCell as TutorPollCollectionViewCell:
            configure(tutorCell, data: data)
        case let fieldCell as QuestionPollCollectionViewCell:
            configure(fieldCell, data: data)
        default:
            break
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let diff = indexPath.row == 0
            ? .zero
            : CGSize(width: 0, height: 150.0)

        return view.frame.size - diff
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    private func configure(_ cell: WelcomeCollectionViewCell, data: QuestionViewModel) {
        cell.delegate = self
        cell.delegatePoll = self
        cell.titleCell.text = data.title
        cell.subtitle.text = data.subtitle
    }
    
    private func configure(_ cell: TutorPollCollectionViewCell, data: QuestionViewModel) {
        cell.delegate = self
        cell.titleCell.text = data.title
        cell.subtitle.text = data.subtitle
    }
    
    private func configure(_ cell: QuestionPollCollectionViewCell, data: QuestionViewModel) {
        cell.delegate = self
        cell.titleCell.text = data.title
    }
}

extension OnboardingWelcomeViewController: PlayVideoCellProtocol {
    
    func playVideoButtonDidSelect() {
        let videoURL: URL = Bundle.main.url(forResource: "video-sample", withExtension: "mp4")!
        let player = AVPlayer(url: videoURL)
        let avPlayerViewController = AVPlayerViewController()
        avPlayerViewController.player = player
        avPlayerViewController.showsPlaybackControls = true
        avPlayerViewController.videoGravity = .resizeAspectFill
        avPlayerViewController.modalPresentationStyle = .fullScreen
        
        modal(avPlayerViewController)
        player.play()
    }
}

extension OnboardingWelcomeViewController: WelcomePollSlideProtocol {
    func next() {
        if viewModel.isLastPageShown {
            push(factory.reportTotalPollViewController())
        } else {
            pollCollection.scrollToItem(at: viewModel.nextIndexPath, at: .bottom, animated: true)
        }
    }
    
    func back() {
        pollCollection.scrollToItem(at: viewModel.backIndexPath, at: .bottom, animated: true)
    }
    
}

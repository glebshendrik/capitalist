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

class OnboardingWelcomeViewController: UIViewController, UIFactoryDependantProtocol {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pollCollection: UICollectionView!
    var viewModel: WelcomePollViewModel!
    private var currentIndex: Int = 0
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
        //        pollCollection.configureForPeekingDelegate()
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
        let data = viewModel.questions[indexPath.row]
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
        let cvRect = self.view.frame.size
        if indexPath.row == 0 {
            return CGSize(width: cvRect.width, height: cvRect.height)
        } else {
            return CGSize(width: cvRect.width, height: cvRect.height - 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    private func configure(_ cell: WelcomeCollectionViewCell, data: WelcomePollViewModel.PollScreenData) {
        cell.delegate = self
        cell.delegatePoll = self
        cell.titleCell.text = data.title
        cell.subtitle.text = data.value
    }
    
    private func configure(_ cell: TutorPollCollectionViewCell, data: WelcomePollViewModel.PollScreenData) {
        cell.delegate = self
        cell.titleCell.text = data.title
        cell.subtitle.text = data.value
    }
    
    private func configure(_ cell: QuestionPollCollectionViewCell, data: WelcomePollViewModel.PollScreenData) {
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
        if currentIndex + 1 == viewModel.numberOfPollQuestions {
            //            next screen
            
            push(OnboardingViewController())
//            self.navigationController?.pushViewController(OnboardingViewController())
        } else {
            
            currentIndex += 1
            let nextIndexPath = IndexPath(row: currentIndex, section: 0)
            pollCollection.scrollToItem(at: nextIndexPath, at: .bottom, animated: true)
        }
    }
    
    func back() {
        if currentIndex == 0 {
            
        } else {
            currentIndex -= 1
            let backIndexPath = IndexPath(row: currentIndex, section: 0)
            pollCollection.scrollToItem(at: backIndexPath, at: .bottom, animated: true)
        }
        
    }
    
}

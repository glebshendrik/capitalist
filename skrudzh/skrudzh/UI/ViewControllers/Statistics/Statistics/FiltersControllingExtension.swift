//
//  StatisticsFiltersControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension StatisticsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSourceOrDestinationFilters
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell,
            let filter = viewModel.sourceOrDestinationFilter(at: indexPath) else {
                return UICollectionViewCell()
        }
        
        cell.viewModel = filter
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let filter = viewModel.sourceOrDestinationFilter(at: indexPath) else {
            return CGSize.zero
        }
        
        let titleSize = filter.title.size(withAttributes: [
            NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13)
            ])
        let edgeInsets = UIEdgeInsets(top: 5.0, left: 6.0, bottom: 3.0, right: 23.0)
        let size = CGSize(width: titleSize.width + edgeInsets.horizontal, height: 24.0)
        
        return size
    }
    
}

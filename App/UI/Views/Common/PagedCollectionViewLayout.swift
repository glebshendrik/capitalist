//
//  PagedCollectionViewLayout.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

//@IBDesignable
open class PagedCollectionViewLayout : UICollectionViewLayout {
    @IBInspectable
    public var columns: Int = 4
    
    @IBInspectable
    public var rows: Int = 6
    
    @IBInspectable
    public var itemSize: CGSize = CGSize(width: 64, height: 64)
    
    @IBInspectable
    public var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    @IBInspectable
    public var sectionEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private var attributes: [UICollectionViewLayoutAttributes] = []
    
    func set(columns: Int) {
        if self.columns != columns {
            self.columns = columns
            self.invalidateLayout()
        }
    }
    
    func set(rows: Int) {
        if self.rows != rows {
            self.rows = rows
            self.invalidateLayout()
        }
    }
    
    func set(itemSize: CGSize) {
        if self.itemSize != itemSize {
            self.itemSize = itemSize
            self.invalidateLayout()
        }
    }
    
    func set(edgeInsets: UIEdgeInsets) {
        if self.edgeInsets != edgeInsets {
            self.edgeInsets = edgeInsets
            self.invalidateLayout()
        }
    }
    
    var numberOfPages: Int {
        guard   let collectionView = collectionView,
            let count = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) else { return 0 }
        
        let pageSize = rows * columns
        return (count + pageSize - 1) / pageSize
    }
    
    open override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        
        let rect = collectionView.bounds.inset(by: edgeInsets)
        var offsetX = edgeInsets.left + sectionEdgeInsets.left
        var offsetY = edgeInsets.top + sectionEdgeInsets.top
        
        var marginX = 0.0
        
        if columns == 1 {
            offsetX += (rect.width - itemSize.width) / 2.0
        } else {
            marginX = Double((rect.width - CGFloat(columns) * itemSize.width) / (CGFloat(columns) - 1))
        }
        
        var marginY = 0.0
        if self.rows == 1 {
            offsetY += (rect.height - itemSize.height) / 2.0
        } else {
            marginY = Double((rect.height - CGFloat(rows) * itemSize.height) / (CGFloat(rows) - 1))
        }
        
        let pageSize = rows * columns
        
        var attrs = [UICollectionViewLayoutAttributes]()
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for number in 0..<numberOfItems {
            let page = number / pageSize
            let col = (number % pageSize) % columns
            let row = (number % pageSize) / columns
            
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: number, section: 0))
            attr.frame = CGRect(x: offsetX + collectionView.bounds.width * CGFloat(page) + (CGFloat(marginX) + itemSize.width) * CGFloat(col),
                                y: offsetY + (CGFloat(marginY) + itemSize.height) * CGFloat(row),
                                width: itemSize.width,
                                height: itemSize.height)
            
            attrs.append(attr)
        }
        
        attributes = attrs
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { rect.intersects($0.frame) }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override var collectionViewContentSize: CGSize {
        
        guard let collectionView = collectionView else { return CGSize.zero }
        
        let size = collectionView.bounds.size
        let collectionViewWidth = collectionView.frame.size.width
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let rightInset = numberOfItems % columns == 0 ? sectionEdgeInsets.right : 0
        let newSize = CGSize(width: CGFloat(numberOfPages) * collectionViewWidth + rightInset,
                             height: size.height)
        
        return newSize
    }
    
    override open func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        
        attributes.alpha = 0.99
        attributes.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        return attributes
    }
}

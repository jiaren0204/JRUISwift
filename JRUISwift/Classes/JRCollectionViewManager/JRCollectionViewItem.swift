//
//  JRCollectionViewItem.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/3/5.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

open class JRCollectionViewItem: NSObject {
    public weak var manager: JRCollectionViewManager!
    public weak var section: JRCollectionViewSection!
    public var cellIdentifier: String!
    public var cellSize: CGSize = .zero
    
    public var indexPath: IndexPath {
        let rowIndex = self.section.items.firstIndex(where: { (item) -> Bool in
            item == self
        })

        let section = manager.sections.firstIndex(where: { (section) -> Bool in
            section == self.section
        })

        return IndexPath(item: rowIndex!, section: section!)
    }
    
    public init(cellClass: AnyClass) {
        super.init()
        self.cellIdentifier = NSStringFromClass(cellClass).components(separatedBy: ".").last
        setupConfig()
        calculate()
    }
    
    public func reload() {
        print("reload tableview at \(indexPath)")
        manager.collectionView.reloadItems(at: [indexPath])
    }

    public func delete() {
        if manager == nil || section == nil {
            print("Item did not in section or manager，please check section.add() method")
            return
        }
        if !section.items.contains(where: { $0 == self }) {
            print("can't delete because this item did not in section")
            return
        }
        let indexPath = self.indexPath
        section.items.remove(at: indexPath.row)
        manager.collectionView.deleteItems(at: [indexPath])
    }
    
    public func map<T: JRCollectionViewItem>(_ type: T.Type) -> T {
        self as! T
    }
    
    public func setupConfig() {}
    public func calculate() {}
}


open class JRCollectionReusableViewItem: NSObject {
    public weak var manager: JRCollectionViewManager!
    public weak var section: JRCollectionViewSection!
    
    public var height: CGFloat = 0
    public var cellIdentifier: String!
    public var cellClass: AnyClass!
    
    public init(cellClass: AnyClass) {
        super.init()
        self.cellIdentifier = NSStringFromClass(type(of: self)).components(separatedBy: ".").last
        self.cellClass = cellClass
        
        setupConfig()
        calculate()
    }
    
    public func map<T: JRCollectionReusableViewItem>(_ type: T.Type) -> T {
        self as! T
    }
    
    public func setupConfig() {}
    public func calculate() {}
}


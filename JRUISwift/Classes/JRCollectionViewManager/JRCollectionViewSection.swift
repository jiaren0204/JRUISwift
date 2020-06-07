//
//  JRCollectionViewSection.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/3/5.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

open class JRCollectionViewSection: NSObject {
    public weak var manager: JRCollectionViewManager!
    public var items = [JRCollectionViewItem]()
    public var headerItem: JRCollectionReusableViewItem?
    public var footerItem: JRCollectionReusableViewItem?
    

    public var index: Int {
        let section = manager.sections.firstIndex(where: { (section) -> Bool in
            section == self
        })
        return section!
    }
    

    // JRCollectionReusableViewItem
    public convenience init(headerItem: JRCollectionReusableViewItem? = nil, footerItem: JRCollectionReusableViewItem? = nil) {
        self.init()
        self.headerItem = headerItem
        self.headerItem?.section = self
        self.headerItem?.manager = manager
        
        self.footerItem = footerItem
        self.footerItem?.section = self
        self.footerItem?.manager = manager
    }
    
    public func add(item: JRCollectionViewItem) {
        item.section = self
        item.manager = manager
        items.append(item)
    }
    
    public func remove(item: JRCollectionViewItem) {
        if let index = items.firstIndex(where: { $0 == item }) {
            items.remove(at: index)
        } else {
            print("item not in this section")
        }
    }

    public func removeAllItems() {
        items.removeAll()
    }
    
    public func replaceItemsFrom(array: [JRCollectionViewItem]!) {
        removeAllItems()
        items = items + array
    }
    
    public func insert(_ item: JRCollectionViewItem!, afterItem: JRCollectionViewItem) {
        if !items.contains(where: { $0 == afterItem }) {
            print("can't insert because afterItem did not in sections")
            return
        }
        
        item.section = self
        item.manager = manager
        items.insert(item, at: items.firstIndex(where: { $0 == afterItem })! + 1)
        manager.collectionView.insertItems(at: [item.indexPath])
    }
    
    public func insert(_ items: [JRCollectionViewItem], afterItem: JRCollectionViewItem) {
        if !self.items.contains(where: { $0 == afterItem }) {
            print("can't insert because afterItem did not in sections")
            return
        }

        let newFirstIndex = self.items.firstIndex(where: { $0 == afterItem })! + 1
        self.items.insert(contentsOf: items, at: newFirstIndex)
        var arrNewIndexPath = [IndexPath]()
        for i in 0 ..< items.count {
            items[i].section = self
            items[i].manager = manager
            arrNewIndexPath.append(IndexPath(item: newFirstIndex + i, section: afterItem.indexPath.section))
        }
        
        manager.collectionView.insertItems(at: arrNewIndexPath)
    }

    public func delete(_ itemsToDelete: [JRCollectionViewItem]) {
        guard itemsToDelete.count > 0 else { return }
        
        var arrNewIndexPath = [IndexPath]()
        for i in itemsToDelete {
            arrNewIndexPath.append(i.indexPath)
        }
        for i in itemsToDelete {
            remove(item: i)
        }
        
        manager.collectionView.deleteItems(at: arrNewIndexPath)
    }
    
    public func reload() {
        if let index = manager.sections.firstIndex(where: { $0 == self }) {
            manager.collectionView.reloadSections(IndexSet(integer: index))
        } else {
            print("section did not in manager！")
        }
    }
}



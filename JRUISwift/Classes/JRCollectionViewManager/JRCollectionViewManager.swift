//
//  JRCollectionView.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/3/5.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

open class JRCollectionViewManager: NSObject {
    
    public var sections = [JRCollectionViewSection]()
    public var collectionView: UICollectionView!
    
    private var cellEventDic = [String: (JRCollectionViewItem, Any?) -> (Void)]()
    private var headerFooterEventDic = [String: (JRCollectionReusableViewItem, Any?) -> (Void)]()
    
    private var didEndScrollingCallback: ((JRCollectionViewItem, Int) -> (Void))?
    
    public init(collectionView: UICollectionView,
                cellClasses: [AnyClass]? = nil,
                headerClasses: [AnyClass]? = nil,
                footerClasses: [AnyClass]? = nil) {
        
        super.init()
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? JRCustomSizeLayout {
            layout.manager = self
        }
        
        // 注册
        if let cellClasses = cellClasses {
            for cellClass in cellClasses {
                registerCell(cellClass)
            }
        }
        
        if let headerClasses = headerClasses {
            for headerClass in headerClasses {
                registerHeadFooter(headerClass, kind: UICollectionView.elementKindSectionHeader)
            }
        }
        
        if let footerClasses = footerClasses {
            for footerClass in footerClasses {
                registerHeadFooter(footerClass, kind: UICollectionView.elementKindSectionFooter)
            }
        }
    }
    
    // MARK: - 注册cell
    public func registerCell(_ cellClass: AnyClass) {
        guard let cellName = NSStringFromClass(cellClass).components(separatedBy: ".").last else {
            return
        }
        
        if Bundle.main.path(forResource: "\(cellClass)", ofType: "nib") != nil {
            collectionView.register(UINib(nibName: "\(cellClass)", bundle: Bundle.main), forCellWithReuseIdentifier: cellName)
        } else {
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellName)
        }
    }
    
    // MARK: - 注册HeaderFooter
    public func registerHeadFooter(_ headerFooterClass: AnyClass, kind: String) {
        guard let headerFooterName = NSStringFromClass(headerFooterClass).components(separatedBy: ".").last else {
            return
        }

        if Bundle.main.path(forResource: "\(headerFooterClass)", ofType: "nib") != nil {
            collectionView.register(UINib(nibName: "\(headerFooterClass)", bundle: Bundle.main), forSupplementaryViewOfKind: kind, withReuseIdentifier: headerFooterName)
        } else {
            collectionView.register(headerFooterClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: headerFooterName)
        }
    }

    
    public func add(section: JRCollectionViewSection) {
        section.manager = self
        sections.append(section)
    }
    
    public func remove(section: JRCollectionViewSection) {
        sections.remove(at: sections.firstIndex(where: { (current) -> Bool in
            current == section
        })!)
    }

    public func removeAllSections() {
        sections.removeAll()
    }
    
    public func reload() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension JRCollectionViewManager: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! JRCollectionViewCell
        cell.didSelect()
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! JRCollectionViewCell).didDisappear()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! JRCollectionViewCell).didDisappear()
    }
}

// MARK: - UICollectionViewDataSource
extension JRCollectionViewManager: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]
        if let headerItem = section.headerItem,
            kind == UICollectionView.elementKindSectionHeader {
            return dequeueReusableView(reusableItem: headerItem, kind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
        }
        
        if let footerItem = section.footerItem,
            kind == UICollectionView.elementKindSectionFooter {
            return dequeueReusableView(reusableItem: footerItem, kind: UICollectionView.elementKindSectionFooter, indexPath: indexPath)
        }
        
        return UICollectionReusableView(frame: .zero)
    }
    
    // MARK: - 找到复用的ReusableView
    public func dequeueReusableView(reusableItem: JRCollectionReusableViewItem, kind: String, indexPath: IndexPath) -> JRCollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reusableItem.cellIdentifier, for: indexPath) as! JRCollectionReusableView
        
        reusableView.item = reusableItem
        reusableView.willAppear()
        
        return reusableView
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentSection = sections[indexPath.section]
        let item = currentSection.items[indexPath.row]
        item.manager = self
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.cellIdentifier, for: indexPath) as! JRCollectionViewCell

        cell.item = item
        cell.update()
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension JRCollectionViewManager: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let didEndScrollingCallback = didEndScrollingCallback,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, layout.scrollDirection == .horizontal,
            let section = sections.first {
            
            let callBackItem = Int(ceilf(Float(scrollView.contentOffset.x / UIScreen.main.bounds.size.width))) % section.items.count
            didEndScrollingCallback(section.items[callBackItem], callBackItem)
        }
    }
}

// MARK: - 事件
extension JRCollectionViewManager {
    // MARK: - 事件注册&调用
    // MARK: 系统
    public func registerDidEndScrollingEvent(callback: @escaping (JRCollectionViewItem, Int)->(Void)) {
        didEndScrollingCallback = callback
    }
    
    // MARK: CELL
    public func registerCellEvent(_ event: String, callback: @escaping (JRCollectionViewItem, Any?)->(Void)) {
        cellEventDic[event] = callback
    }
    
    public func performCellEvent(_ event: String, item: JRCollectionViewItem, msg: Any? = nil) {
        cellEventDic[event]?(item, msg)
    }
    
    public func registerHeaderFooterEvent(_ event: String, callback: @escaping (JRCollectionReusableViewItem, Any?)->(Void)) {
        headerFooterEventDic[event] = callback
    }
    
    public func performHeaderFooterEvent(_ event: String, item: JRCollectionReusableViewItem, msg: Any? = nil) {
        headerFooterEventDic[event]?(item, msg)
    }
}

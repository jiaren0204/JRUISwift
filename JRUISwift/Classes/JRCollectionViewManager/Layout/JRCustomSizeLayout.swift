//
//  JRCustomSizeLayout.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/3/19.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

/// 使用 JRCustomSizeLayout ,处理数据使用JRCollectionViewManager和JRCollectionViewSection
/// 不要直接使用collectionView处理

import UIKit

public class JRCustomSizeLayout: UICollectionViewFlowLayout {
    public weak var manager: JRCollectionViewManager! {
        didSet {
            layoutTool.clean()
        }
    }
    private var layoutTool: JRCustomSizeLayoutTool
    
    private var collectViewW: CGFloat = 0
    
    override init() {
        self.layoutTool = JRCustomSizeLayoutTool()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepare() {
        super.prepare()
        collectViewW = manager.collectionView.width - manager.collectionView.contentInset.left - manager.collectionView.contentInset.right
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        let section = manager.sections[indexPath.section]
        // 头部
        if let headerItem = section.headerItem,
            elementKind == UICollectionView.elementKindSectionHeader {
            
            if let headerFrame = layoutTool.querySectionHeaderFrame(section: indexPath.section) {
                attributes.frame = headerFrame
            } else {
                var lastSectionMaxY: CGFloat = 0
                if indexPath.section > 0 {
                    lastSectionMaxY = layoutTool.querySectionMaxY(section: (indexPath.section - 1)) + CGFloat(minimumLineSpacing)
                }
                
                attributes.frame = CGRect(x: 0, y: lastSectionMaxY, width: collectViewW, height: headerItem.height)
                
                layoutTool.setSection(section: indexPath.section, headerFrame: attributes.frame)
                layoutTool.setSection(section: indexPath.section, sectionMaxY: lastSectionMaxY + headerItem.height)
            }
        }
        
        // 脚部
        if let footerItem = section.footerItem,
            elementKind == UICollectionView.elementKindSectionFooter {
            
            if let footerFrame = layoutTool.querySectionFooterFrame(section: indexPath.section) {
                attributes.frame = footerFrame
            } else {
                // 取出当前section的最大Y值
                let sectionMaxY = layoutTool.querySectionMaxY(section: indexPath.section)
                
                attributes.frame = CGRect(x: 0, y: sectionMaxY, width: collectViewW, height: footerItem.height)
                
                layoutTool.setSection(section: indexPath.section, footerFrame: attributes.frame)

                // 每组的总高度(+footer)
                layoutTool.setSection(section: indexPath.section, sectionMaxY: sectionMaxY + footerItem.height)
            }
        }
        return attributes
    }
    
    // MARK: - 设置每一个item的属性
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let section = manager.sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        attributes.size = item.cellSize
        
        /** 计算每一组,一行个数,多少行,一行item的Size */
        if layoutTool.hasSectionInfo(section: indexPath.section) == false { // 当前组没有任何计算数据
            if scrollDirection == .vertical {
                verticalLayout(section: section, indexPath: indexPath)
            } else {
                horizontalLayout(section: section, indexPath: indexPath)
            }
        }

        /** 计算indexPath属于第几行,第几列 */
        var row = 0
        var col = 0
        calculateCurrentItem(row: &row, col: &col, indexPath: indexPath)
        
        if let currentFrame = layoutTool.queryItemFrame(section: indexPath.section, item: indexPath.item) {
            attributes.frame = currentFrame
        } else {
            let rowSizeArr = layoutTool.queryItemSizes(section: indexPath.section, row: row)
            
            if scrollDirection == .vertical {
                let headerFrame = layoutTool.querySectionHeaderFrame(section: indexPath.section) ?? .zero

                /** 把上一section的高度取出来 */
                var previousSectionMaxY = CGFloat(0)
                if indexPath.section > 0 {
                    previousSectionMaxY = layoutTool.querySectionMaxY(section: (indexPath.section - 1)) + (headerFrame.height > 0 ? self.minimumLineSpacing : 0)
                }
                
                // 当前item上面每一行最大高高度+minimumLineSpacing
                var originY = CGFloat(0)
                for i in 0..<row {
                    let maxHeight = layoutTool.queryItemSizes(section: indexPath.section, row: i).compactMap { $0.height }.max() ?? 0
                    
                    originY += (maxHeight + minimumLineSpacing)
                }
                
                let itemY = previousSectionMaxY + originY + (headerFrame.height > 0 ? headerFrame.height : self.minimumLineSpacing);
                
                // 当前item前面所有item+minimumInteritemSpacing的宽度
                var originX = CGFloat(0)
                for i in 0..<col {
                    originX += rowSizeArr[i].width + minimumInteritemSpacing
                }
  
                let itemX = sectionInset.left + originX
                
                // 每组的总高度(最后一行:ItemY+最高的item+footer)
                
                if indexPath.item == section.items.count - 1 {
                    let maxHeight = layoutTool.queryItemSizes(section: indexPath.section, row: row).compactMap { $0.height }.max() ?? 0
                    
                    let sectionMaxY = itemY + maxHeight + sectionInset.top + sectionInset.bottom
                    layoutTool.setSection(section: indexPath.section, sectionMaxY: sectionMaxY)
                }
                
                attributes.frame = CGRect(x: itemX, y: itemY, width: attributes.size.width, height: attributes.size.height)
                layoutTool.setSection(section: indexPath.section, item: indexPath.item, itemFrame: attributes.frame)
            } else {

                // 当前item前面所有item+minimumInteritemSpacing的宽度
                var originX = CGFloat(0)
                for i in 0..<indexPath.item{
                    originX += rowSizeArr[i].width + minimumInteritemSpacing
                }

                let itemX = sectionInset.left + originX
                
                attributes.frame = CGRect(x: itemX, y: minimumLineSpacing, width: attributes.size.width, height: attributes.size.height)
                layoutTool.setSection(section: indexPath.section, item: indexPath.item, itemFrame: attributes.frame)
                
                if indexPath.item == section.items.count - 1 {
                    layoutTool.collectionViewTotalWidth = itemX + rowSizeArr[indexPath.item].width
                }
            }
        }
        
        return attributes
    }
    
    private func verticalLayout(section: JRCollectionViewSection, indexPath: IndexPath) {
        var rowItem = 0
        var row = 0
        var maxRowWidth = CGFloat(0)
        
        var itemSizeArr = [CGRect]()
        
        for item in section.items {
            maxRowWidth += (item.cellSize.width + minimumInteritemSpacing)
            
            if maxRowWidth <= collectViewW ||
               (maxRowWidth - minimumInteritemSpacing) <= collectViewW { //  超出collectView宽度换行
                itemSizeArr.append(CGRect(origin: .zero, size: item.cellSize))
                rowItem += 1
            } else {
                maxRowWidth = (item.cellSize.width + minimumInteritemSpacing)
                layoutTool.setSection(section: indexPath.section, row: row, itemSizes: itemSizeArr)
                
                itemSizeArr.removeAll()
                itemSizeArr.append(CGRect(origin: .zero, size: item.cellSize))
                rowItem = 1
                row += 1
            }
            
            // 设置:一行有多少个item
            layoutTool.setSection(section: indexPath.section, row: row, numberOfItems: rowItem)
            // 设置:一组有多少行
            layoutTool.setSection(section: indexPath.section, numberOfRows: (row + 1))
        }
        
        // 设置:一行所有item的Size
        if itemSizeArr.isEmpty == false {
            layoutTool.setSection(section: indexPath.section, row: row, itemSizes: itemSizeArr)
        }
    }
    
    private func horizontalLayout(section: JRCollectionViewSection, indexPath: IndexPath) {
        var itemSizeArr = [CGRect]()
        
        let itemsCount = section.items.count
        for (i, item) in section.items.enumerated() {
            itemSizeArr.append(CGRect(origin: .zero, size: item.cellSize))
            
            if i == itemsCount - 1 {
                layoutTool.setSection(section: indexPath.section, row: 0, itemSizes: itemSizeArr)
            }
        }
    }
    
    // MARK - 计算当前item的row和col
    private func calculateCurrentItem(row: inout Int, col: inout Int, indexPath: IndexPath) {
        var totalItem = 0
        let rowCount = layoutTool.queryNumberOfRows(section: indexPath.section)
        
        for i in 0..<rowCount {
            let numOfItems = layoutTool.queryNumberOfItems(section: indexPath.section, row: i)
            
            totalItem += numOfItems
            
            if Int(CGFloat(indexPath.item * 1) / CGFloat(totalItem)) == 0 {
                row = i
                
                if (row > 0) {
                    col = indexPath.item - (totalItem - numOfItems)
                }
                else {
                    col = indexPath.item
                }
                break
            }
        }
    }

    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArr = [UICollectionViewLayoutAttributes]()
        
        var visiableRect = CGRect.zero
        visiableRect.size = manager.collectionView.size
        visiableRect.origin = manager.collectionView.contentOffset

        for (s, section) in manager.sections.enumerated() {
            if let _ = section.headerItem,
                let headerAttri = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: s)) {
                attributesArr.append(headerAttri)
            }
            
            for item in 0..<section.items.count {
                let indexPath = IndexPath(item: item, section: s)
                if let attributes = layoutAttributesForItem(at: indexPath),
                    visiableRect.intersects(attributes.frame){
                    attributesArr.append(attributes)
                }
            }
            
            if let _ = section.footerItem,
                let footerAttri = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: s)) {
                attributesArr.append(footerAttri)
            }
        }

        return attributesArr
    }
    
    public override var collectionViewContentSize: CGSize {
        var contentSize = CGSize.zero
        
        if scrollDirection == .vertical {
            contentSize = CGSize(width: collectViewW, height: layoutTool.collectionViewTotalHeight)
        }
        else {
            contentSize = CGSize(width: layoutTool.collectionViewTotalWidth, height:  manager.collectionView.height);
        }
        
        return contentSize
    }
}

fileprivate struct JRSectionInfo {
    var numberOfRows: Int = 0
    var sectionMaxY: CGFloat = 0
    var totalWidth: CGFloat = 0
    var headerFrame: CGRect = .zero
    var footerFrame: CGRect = .zero
    
    var numberOfItemsDic = [Int: Int]()
    var itemSizesDic = [Int: [CGRect]]()
    var itemFrameDic = [Int: CGRect]()
}

fileprivate enum JRSectionInfoValue: Int {
    case rows
    case sectionMaxY
    case headerFrame
    case footerFrame
    case numberOfItems
    case itemSizes
    case itemFrame
}

fileprivate class JRCustomSizeLayoutTool {
    var sectionInfoDic = [Int: JRSectionInfo]()
    var collectionViewTotalWidth: CGFloat = 0
    
    func hasSectionInfo(section: Int) -> Bool {
        guard let numberOfItemsDic = sectionInfoDic[section]?.numberOfItemsDic else {
            return false
        }
        return numberOfItemsDic.count != 0
    }
    
    private func setValue(type: JRSectionInfoValue, section: Int, key: Int = 0, value: Any) {
        var info = sectionInfoDic[section] ?? JRSectionInfo()

        switch type {
        case .rows:
            info.numberOfRows = value as! Int
        case .sectionMaxY:
            info.sectionMaxY = value as! CGFloat
        case .headerFrame:
            info.headerFrame = value as! CGRect
        case .footerFrame:
            info.footerFrame = value as! CGRect
        case .numberOfItems:
            info.numberOfItemsDic[key] = value as? Int
        case .itemSizes:
            info.itemSizesDic[key] = value as? [CGRect]
        case .itemFrame:
            info.itemFrameDic[key] = value as? CGRect
        }
        
        sectionInfoDic[section] = info
    }
    
    func setSection(section: Int, numberOfRows: Int) {
        setValue(type: .rows, section: section, value: numberOfRows)
    }
   
    func setSection(section: Int, sectionMaxY: CGFloat) {
        setValue(type: .sectionMaxY, section: section, value: sectionMaxY)
    }
    
    func setSection(section: Int, headerFrame: CGRect) {
        setValue(type: .headerFrame, section: section, value: headerFrame)
    }
    
    func setSection(section: Int, footerFrame: CGRect) {
        setValue(type: .footerFrame, section: section, value: footerFrame)
    }
    
    func setSection(section: Int, row: Int, numberOfItems: Int) {
        setValue(type: .numberOfItems, section: section, key: row, value: numberOfItems)
    }
    
    func setSection(section: Int, row: Int, itemSizes: [CGRect]) {
        setValue(type: .itemSizes, section: section, key: row, value: itemSizes)
    }
    
    func setSection(section: Int, item: Int, itemFrame: CGRect) {
        setValue(type: .itemFrame, section: section, key: item, value: itemFrame)
    }
    
    // MARK: - 查询功能
    // MARK: 查询section的总行数
    func queryNumberOfRows(section: Int) -> Int {
        sectionInfoDic[section]?.numberOfRows ?? 0
    }
    
    // MARK: 查询section的最大Y值
    func querySectionMaxY(section: Int) -> CGFloat {
        sectionInfoDic[section]?.sectionMaxY ?? 0
    }
    
    // MARK: 查询section的header高度
    func querySectionHeaderFrame(section: Int) -> CGRect? {
        sectionInfoDic[section]?.headerFrame
    }
    
    // MARK: 查询section的footer高度
    func querySectionFooterFrame(section: Int) -> CGRect? {
        sectionInfoDic[section]?.footerFrame
    }
    
    // MARK: 查询一行的item个数
    func queryNumberOfItems(section: Int, row: Int) -> Int {
        sectionInfoDic[section]?.numberOfItemsDic[row] ?? 0
    }
    
    // MARK: 查询一行的item的Size
    func queryItemSizes(section: Int, row: Int) -> [CGRect] {
        sectionInfoDic[section]?.itemSizesDic[row] ?? [CGRect]()
    }
    
    // MARK: 查询item的Size
    func queryItemFrame(section: Int, item: Int) -> CGRect? {
        sectionInfoDic[section]?.itemFrameDic[item]
    }
    
    var collectionViewTotalHeight: CGFloat {
        sectionInfoDic.compactMap { $1.sectionMaxY }.max() ?? 0
    }
    
    func clean() {
        sectionInfoDic.removeAll()
    }
    
}

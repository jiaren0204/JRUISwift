//
//  JRCollectionViewCell.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/3/5.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

class JRCollectionViewCell: UICollectionViewCell {
    public var item: JRCollectionViewItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfig()
        defaultSet()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfig()
        defaultSet()
    }
    
    private func defaultSet() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    public func performCellEvent(_ event: String, msg: Any? = nil) {
        item.manager.performCellEvent(event, item: item, msg: msg)
    }
    
    public func setupConfig() { }

    public func update() {}

    public func didAppear() {}

    public func didDisappear() {}
    
    public func didSelect() {}
    
}

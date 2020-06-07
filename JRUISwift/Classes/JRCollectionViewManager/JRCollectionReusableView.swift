//
//  JRCollectionReusableView.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/3/18.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

public class JRCollectionReusableView: UICollectionReusableView {
    public var item: JRCollectionReusableViewItem!

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

    open func performCellEvent(_ event: String, msg: Any? = nil) {
        item.manager.performHeaderFooterEvent(event, item: item, msg: msg)
    }

    open func setupConfig() { }

    open func willAppear() {}
}

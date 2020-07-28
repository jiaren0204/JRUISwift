//
//  JRTableViewHeaderFooterView.swift
//  workDemo
//
//  Created by mac on 2020/5/13.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
open class JRTableViewHeaderFooterView: UITableViewHeaderFooterView {
    public var cellItem: JRTableViewHeaderFooterItem!

    open override func awakeFromNib() {
        super.awakeFromNib()
        setupConfig()
    }
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupConfig()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    open func setupConfig() { }
    open func update() {}
    
    open func performHeaderFooterEvent(_ event: JRTableViewEvent, msg: Any? = nil) {
        cellItem.tableViewManager.performHeaderFooterEvent(event, item: cellItem, msg: msg)
    }
    
}

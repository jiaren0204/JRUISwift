//
//  JRTableViewHeaderFooterItem.swift
//  workDemo
//
//  Created by mac on 2020/5/13.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import UIKit

open class JRTableViewHeaderFooterItem: NSObject {
    
    public weak var tableViewManager: JRTableViewManager!
    public weak var section: JRTableViewSection!
    public var cellIdentifier: String!
    public var height: CGFloat!

    
    public init(headerFooterClass: AnyClass, height: CGFloat) {
        super.init()
        self.cellIdentifier = NSStringFromClass(headerFooterClass).components(separatedBy: ".").last
        self.height = height
        setupConfig()
        calculate()
    }
    
    public func map<T: JRTableViewHeaderFooterItem>(_ type: T.Type) -> T {
        self as! T
    }

    
    public func setupConfig() {}
    public func calculate() {}
}

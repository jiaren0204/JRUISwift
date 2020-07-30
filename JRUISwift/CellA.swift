//
//  CellA.swift
//  JRUISwift
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

class CellAItem: JRTableViewItem {

    var page: Int
    
    init(page: Int) {
        self.page = page
        super.init(cellClass: CellA.self, cellHeight: 60)
    }
}


class CellA: JRTableViewCell {

//    override func setupConfig() {
//        backgroundColor = .cyan
//    }
//
//    override func update() {
//
//    }
}

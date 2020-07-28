//
//  ViewController.swift
//  JRUISwift
//
//  Created by 梁嘉仁 on 2020/6/7.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit
import Then
import SnapKit

class ViewController: UIViewController {

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .red
        view.addSubview($0)
        $0.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private var tableMgr: JRTableViewManager!
    private let section = JRTableViewSection()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableMgr = JRTableViewManager(tableView: tableView, cellClasses: [CellA.self])
        tableMgr.add(section: section)
        
        section.add(item: CellAItem(page: 3))
        tableMgr.reload()
    }


}


//
//  ViewController.swift
//  JRUISwift
//
//  Created by 梁嘉仁 on 2020/6/7.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

class CC {
    
}

class ViewController: UIViewController {
    
    private var sysEventDic = [UnsafeMutableRawPointer: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let c = CC();
        
        let key = Unmanaged.passUnretained(c).toOpaque()
        sysEventDic[key] = "1"
        
//        print(Unmanaged.passUnretained(c).toOpaque())
        
        sysEventDic.forEach { (key, value) in
            print(value)
        }
        

    }


}


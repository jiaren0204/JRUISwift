//
//  UIView+frame.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/2/11.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var x: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.x = newValue;
            self.frame = frame;
        }
        get { self.frame.origin.x }
    }
    
    var y: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.y = newValue;
            self.frame = frame;
        }
        get { self.frame.origin.y }
    }
    
    var centerX: CGFloat {
        set {
            var center = self.center;
            center.x = newValue;
            self.center = center;
        }
        get { self.center.x }
    }
    
    var centerY: CGFloat {
        set {
            var center = self.center;
            center.y = newValue;
            self.center = center;
        }
        get { self.center.y }
    }
    
    var width: CGFloat {
        set {
            var frame = self.frame;
            frame.size.width = newValue;
            self.frame = frame;
        }
        get { self.frame.size.width }
    }
    
    var height: CGFloat {
        set {
            var frame = self.frame;
            frame.size.height = newValue;
            self.frame = frame;
        }
        get { self.frame.size.height }
    }
    
    var size: CGSize {
        set {
            var frame = self.frame;
            frame.size = newValue;
            self.frame = frame;
        }
        get { self.frame.size }
    }
}

//
//  JRPopupViewBaseAnimator.swift
//  workDemo
//
//  Created by mac on 2020/5/13.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import UIKit

public protocol JRPopupViewAnimationProtocol: AnyObject {
    func setup(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, containerView: UIView)
    
    func display(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, animated: Bool, completion: @escaping ()->())

    func dismiss(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, animated: Bool, completion: @escaping ()->())
}


open class JRPopupViewBaseAnimator: JRPopupViewAnimationProtocol {
    open var displayDuration: TimeInterval = 0.25
    open var displayAnimationOptions = UIView.AnimationOptions.init(rawValue: UIView.AnimationOptions.beginFromCurrentState.rawValue & UIView.AnimationOptions.curveEaseInOut.rawValue)
    /// 展示动画的配置block
    open var displayAnimateBlock: (()->())?

    open var dismissDuration: TimeInterval = 0.25
    open var dismissAnimationOptions = UIView.AnimationOptions.init(rawValue: UIView.AnimationOptions.beginFromCurrentState.rawValue & UIView.AnimationOptions.curveEaseInOut.rawValue)
    /// 消失动画的配置block
    open var dismissAnimateBlock: (()->())?

    public init() {
    }

    open func setup(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, containerView: UIView) {
    }

    open func display(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, animated: Bool, completion: @escaping () -> ()) {
        if animated {
            UIView.animate(withDuration: displayDuration, delay: 0, options: displayAnimationOptions, animations: {
                self.displayAnimateBlock?()
            }) { (finished) in
                completion()
            }
        } else {
            self.displayAnimateBlock?()
            completion()
        }
    }

    open func dismiss(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, animated: Bool, completion: @escaping () -> ()) {
        if animated {
            UIView.animate(withDuration: dismissDuration, delay: 0, options: dismissAnimationOptions, animations: {
                self.dismissAnimateBlock?()
            }) { (finished) in
                completion()
            }
        } else {
            self.dismissAnimateBlock?()
            completion()
        }
    }
}

open class JRPopupViewAlphaAnimator: JRPopupViewBaseAnimator {
    open override func setup(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, containerView: UIView) {
        
        contentView.alpha = 0
        backgroundView.alpha = 0
        
        displayAnimateBlock = {
            contentView.alpha = 1
            backgroundView.alpha = 1
        }
        dismissAnimateBlock = {
            contentView.alpha = 0
            backgroundView.alpha = 0
        }
    }
}

open class JRPopupViewTopAnimator: JRPopupViewBaseAnimator {
    open override func setup(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, containerView: UIView) {
        
        backgroundView.alpha = 0
        contentView.y = -contentView.height
        
        displayAnimateBlock = {
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.height)
            backgroundView.alpha = 1
        }
        dismissAnimateBlock = {
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.height)
            backgroundView.alpha = 0
        }
    }
}

open class JRPopupViewBottomAnimator: JRPopupViewBaseAnimator {
    open override func setup(contentView: JRPopUpViewConfigProtocol, backgroundView: UIButton, containerView: UIView) {
        
        backgroundView.alpha = 0
        contentView.y = contentView.height

        displayAnimateBlock = {
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.height)
            backgroundView.alpha = 1
        }
        dismissAnimateBlock = {
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.height)
            backgroundView.alpha = 0
        }
    }
}

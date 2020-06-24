//
//  JRPopUpView.swift
//  CaiHongShu_Swift
//
//  Created by 梁嘉仁 on 2020/2/10.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import UIKit

public protocol JRPopUpViewConfigProtocol: UIView {
    var viewSize: CGSize { get }
    var customPoint: CGPoint { get }
    var customCenter: CGPoint { get }
}

extension JRPopUpViewConfigProtocol {
    var customPoint: CGPoint {
        get { .zero }
    }
    
    var customCenter: CGPoint {
        get { .zero }
    }
}

// MARK: JRPopAttributes 属性配置
public struct JRPopAttributes {
    
    // MARK: Identification
//    public var name: String?
    
    // MARK: Display Attributes
    public var containerView: UIView = UIApplication.shared.windows.first!
    
    // MARK: 初始化位置
    public var appearType = JRPopUpView.JRPopUpAppearType.center

    // MARK: 点击遮罩关闭
    public var isDismissible = true
    
    // MARK: 点击遮罩颜色
    public var bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    
    // MARK: 遵从协议JXPopupViewAnimationProtocol的动画驱动器
    public var animator: JRPopupViewAnimationProtocol = JRPopupViewAlphaAnimator()
    
    // MARK: 是否取消之前存在的view
    public var dismissExistViews = true
}

public class JRPopUpView: UIView {
    
    public enum JRPopUpAppearType {
        case top
        case center
        case bottom
        case customCenter
        case customPoint
    }

    private var isAnimating = false
    private let attri: JRPopAttributes
    private var statusCallback: ((Bool)->())?
    private var statusWithAnimCallback: ((Bool)->())?

    public lazy var backgroundView: UIButton = {
        let bgView = UIButton()
        bgView.adjustsImageWhenHighlighted = false
        bgView.addTarget(self, action: #selector(backgroundViewClicked), for: .touchUpInside)
        return bgView
    }()
    
    weak var containerView: UIView!
    let contentView: JRPopUpViewConfigProtocol
    
    public init(contentView: JRPopUpViewConfigProtocol,
                attri: JRPopAttributes) {
        self.containerView = attri.containerView
        self.contentView = contentView
        self.attri = attri
        
        super.init(frame: containerView.bounds)
        
        setupConfig()
        setupFrame()
        
        attri.animator.setup(contentView: contentView, backgroundView: backgroundView, containerView: containerView)
    }
    
    private func setupConfig() {
        backgroundView.isUserInteractionEnabled = attri.isDismissible
        backgroundView.backgroundColor = attri.bgColor

        addSubview(backgroundView)
        
    }
    
    private func setupFrame() {
        contentView.size = contentView.viewSize
        
        switch attri.appearType {
        case .top:
            contentView.centerX = containerView.width * 0.5;
            contentView.y = 0;
        case .center:
            let screenSize = UIScreen.main.bounds.size
            contentView.center = CGPoint(x: screenSize.width * 0.5, y: screenSize.height * 0.5)
        case .bottom:
            contentView.centerX = containerView.width * 0.5;
            contentView.y = containerView.height - contentView.height;
        case .customCenter:
            contentView.center = contentView.customCenter
        case .customPoint:
            contentView.x = contentView.customPoint.x
            contentView.y = contentView.customPoint.y
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = self.bounds
    }
    

    public class func dismissAllContentView(containerView: UIView, animated: Bool) {
        for view in containerView.subviews {
            if let popUp = view as? JRPopUpView {
                popUp.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    public class func dismissTargetClass(containerView: UIView, targetClass: AnyClass, animated: Bool) {
        for view in containerView.subviews {
            if let popUp = view as? JRPopUpView, popUp.isKind(of: targetClass) {
                popUp.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func checkAddPopUpView() {
        
        for view in containerView.subviews {
            if view == self {
                let popUp = view as! JRPopUpView
                popUp.dismiss(animated: true, completion: nil)
            }
            
            if let popUp = view as? JRPopUpView {
                popUp.removeFromSuperview()
                popUp.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public func display(animated: Bool, completion: (()->())?) {
        if attri.dismissExistViews {
            checkAddPopUpView()
        }
        
        if isAnimating { return }
        
        isAnimating = true
        
        addSubview(contentView)
        containerView.addSubview(self)
        
        self.statusCallback?(true)

        attri.animator.display(contentView: contentView, backgroundView: backgroundView, animated: animated, completion: {
            completion?()
            self.isAnimating = false
            self.statusWithAnimCallback?(true)
        })
    }
    
    public func dismiss(animated: Bool, completion: (()->())? = nil) {
        if isAnimating {
            return
        }
        
        isAnimating = true
        self.statusCallback?(false)
        
        attri.animator.dismiss(contentView: contentView, backgroundView: backgroundView, animated: animated, completion: {
            self.contentView.removeFromSuperview()
            self.removeFromSuperview()
            completion?()
            self.isAnimating = false
            self.statusWithAnimCallback?(false)
        })
    }
    
    public func dismiss(animated: Bool, after: TimeInterval, completion: (()->())? = nil) {
        
        Timer.scheduledTimer(withTimeInterval: after, repeats: false) { [weak self](_) in
            guard let `self` = self else { return }
            self.dismiss(animated: animated, completion: completion)
        }
    }

    @objc private func backgroundViewClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.endEditing(true)
    }
    
    public func observeStatusChanged(statusCallback: @escaping ((Bool)->())) {
        self.statusCallback = statusCallback
    }
    
    public func observeStatusChangedWithAnim(statusWithAnimCallback: @escaping ((Bool)->())) {
        self.statusWithAnimCallback = statusWithAnimCallback
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






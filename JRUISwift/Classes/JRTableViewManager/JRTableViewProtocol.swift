//
//  JRTableViewProtocol.swift
//  JRUISwift
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 梁嘉仁. All rights reserved.
//

import Foundation
import UIKit

public protocol JRTableItemProtocol where Self: JRTableViewItem {}
extension JRTableViewItem: JRTableItemProtocol {}

public protocol JRTableBaseCellProtocol where Self: UITableViewCell {
    var _item: JRTableItemProtocol? { get set }
    
    func setupConfig()
    func update()
    func didAppear()
    func didDisappear()
    func didSelect()
    func didHighlight()
    func didUnhighlight()
}

public extension JRTableBaseCellProtocol {
    func setupConfig() {}
    func update() {}
    func didAppear() {}
    func didDisappear() {}
    func didSelect() {}
    func didHighlight() {}
    func didUnhighlight() {}
}

public protocol JRTableCellProtocol: JRTableBaseCellProtocol {
    associatedtype T: JRTableItemProtocol
    var item: T! { get set }
}

public extension JRTableCellProtocol {
    
    var _item: JRTableItemProtocol? {
        get { item }
        set {
            item = (newValue as! Self.T)
        }
    }
}


// MARK: - JRTableViewScrollDelegate
public protocol JRTableViewScrollDelegate: NSObjectProtocol {
    @available(iOS 2.0, *)
    func scrollViewDidScroll(_ scrollView: UIScrollView) // any offset changes

    @available(iOS 3.2, *)
    func scrollViewDidZoom(_ scrollView: UIScrollView) // any zoom scale changes

    // called on start of dragging (may require some time and or distance to move)
    @available(iOS 2.0, *)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)

    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @available(iOS 5.0, *)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)

    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @available(iOS 2.0, *)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)

    @available(iOS 2.0, *)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) // called on finger up as we are moving

    @available(iOS 2.0, *)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) // called when scroll view grinds to a halt

    @available(iOS 2.0, *)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating

    @available(iOS 2.0, *)
    func viewForZooming(in scrollView: UIScrollView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens

    @available(iOS 3.2, *)
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) // called before the scroll view begins zooming its content

    @available(iOS 2.0, *)
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) // scale between minimum and maximum. called after any 'bounce' animations

    @available(iOS 2.0, *)
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool // return a yes if you want to scroll to the top. if not defined, assumes YES

    @available(iOS 2.0, *)
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) // called when scrolling animation finished. may be called immediately if already at top

    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
}


// MARK: - JRTableViewScrollDelegate Default Implementation
public extension JRTableViewScrollDelegate {
    func scrollViewDidScroll(_: UIScrollView) {}

    func scrollViewDidZoom(_: UIScrollView) {}

    func scrollViewWillBeginDragging(_: UIScrollView) {}

    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset _: UnsafeMutablePointer<CGPoint>) {}

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {}

    func scrollViewWillBeginDecelerating(_: UIScrollView) {}

    func scrollViewDidEndDecelerating(_: UIScrollView) {}

    func scrollViewDidEndScrollingAnimation(_: UIScrollView) {}

    func viewForZooming(in _: UIScrollView) -> UIView? { return nil }

    func scrollViewWillBeginZooming(_: UIScrollView, with _: UIView?) {}

    func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale _: CGFloat) {}

    func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool { return true }

    func scrollViewDidScrollToTop(_: UIScrollView) {}

    func scrollViewDidChangeAdjustedContentInset(_: UIScrollView) {}
}

// MARK: - UIScrollViewDelegate

extension JRTableViewManager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewDidScroll(scrollView)
        }
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewDidZoom(scrollView)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewWillBeginDragging(scrollView)
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let d = scrollDelegate {
            d.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let d = scrollDelegate {
            d.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewWillBeginDecelerating(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewDidEndDecelerating(scrollView)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewDidEndScrollingAnimation(scrollView)
        }
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if let d = scrollDelegate {
            return d.viewForZooming(in: scrollView)
        }
        return nil
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if let d = scrollDelegate {
            d.scrollViewWillBeginZooming(scrollView, with: view)
        }
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if let d = scrollDelegate {
            d.scrollViewDidEndZooming(scrollView, with: view, atScale: scale)
        }
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let d = scrollDelegate {
            return d.scrollViewShouldScrollToTop(scrollView)
        }
        return true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewDidScrollToTop(scrollView)
        }
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        if let d = scrollDelegate {
            d.scrollViewDidChangeAdjustedContentInset(scrollView)
        }
    }
}

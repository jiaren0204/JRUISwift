import UIKit

open class JRTableViewCell: UITableViewCell, JRTableCellProtocol {
    public typealias T = JRTableViewItem
    public var item: JRTableViewItem!


//    open func performCellEvent(_ event: JRTableViewEvent, msg: Any? = nil) {
//        cellItem.tableViewManager.performCellEvent(event, item: cellItem, msg: msg)
//    }
}

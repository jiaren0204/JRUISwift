import UIKit
public typealias JRTableViewItemBlock = (JRTableViewItem) -> Void

open class JRTableViewItem: NSObject {
    public weak var tableViewManager: JRTableViewManager!
    public weak var section: JRTableViewSection!
    public var cellIdentifier: String!

    /// cell高度(如果要自动计算高度，使用autoHeight(manager)方法，框架会算出高度，具体看demo)
    /// 传UITableViewAutomaticDimension则是系统实时计算高度，可能会有卡顿、reload弹跳等问题，不建议使用，有特殊需要可以选择使用
    public var cellHeight: CGFloat!
    /// 系统默认样式的cell
    public var cellStyle = UITableViewCell.CellStyle.default
    /// cell点击事件的回调
//    public var selectionHandler: JRTableViewItemBlock?
//    public func setSelectionHandler(selectHandler: JRTableViewItemBlock?) {
//        selectionHandler = selectHandler
//    }

    public var deletionHandler: JRTableViewItemBlock?
    public func setDeletionHandler(deletionHandler: JRTableViewItemBlock?) {
        self.deletionHandler = deletionHandler
    }

    public var separatorInset: UIEdgeInsets?
    public var accessoryType: UITableViewCell.AccessoryType?
    public var selectionStyle: UITableViewCell.SelectionStyle = UITableViewCell.SelectionStyle.none
    public var editingStyle: UITableViewCell.EditingStyle = UITableViewCell.EditingStyle.none
    public var isAutoDeselect: Bool! = true
    public var isHideSeparator: Bool = false
    public var separatorLeftMargin: CGFloat = 15
    public var indexPath: IndexPath {
        let rowIndex = self.section.items.firstIndex(where: { (item) -> Bool in
            item == self
        })

        let section = tableViewManager.sections.firstIndex(where: { (section) -> Bool in
            section == self.section
        })

        return IndexPath(item: rowIndex!, section: section!)
    }
    
    public init(cellClass: AnyClass, cellHeight: CGFloat) {
        super.init()
        self.cellIdentifier = NSStringFromClass(cellClass).components(separatedBy: ".").last
        self.cellHeight = cellHeight
        setupConfig()
        calculate()
    }
    
    private func canOperation() -> Bool {
        if tableViewManager == nil || section == nil {
            print("Item did not in section or manager，please check section.add() method")
            return false
        }
        if !section.items.contains(where: { $0 == self }) {
            print("can't reload because this item did not in section")
            return false
        }
        return true
    }

    public func reload(_ animation: UITableView.RowAnimation) {
        if canOperation() == false {
            return
        }

        tableViewManager.tableView.beginUpdates()
        tableViewManager.tableView.reloadRows(at: [indexPath], with: animation)
        tableViewManager.tableView.endUpdates()
    }

    public func delete(_ animation: UITableView.RowAnimation = .automatic) {
        if canOperation() == false {
            return
        }
        
        let indexPath = self.indexPath
        section.items.remove(at: indexPath.row)
        tableViewManager.tableView.deleteRows(at: [indexPath], with: animation)
    }

    /// 计算cell高度
    ///
    /// - Parameters:
    ///   - manager: 当前tableview的manager
    public func autoHeight(_ manager: JRTableViewManager) {
        tableViewManager = manager
        let cell = manager.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? JRTableViewCell
        if cell == nil {
            print("please register cell")
        } else {
            cell?.item = self
            cellHeight = systemFittingHeightForConfiguratedCell(cell!)
        }
    }

    public func systemFittingHeightForConfiguratedCell(_ cell: JRTableViewCell) -> CGFloat {
        cell.update()
        let height = cell.systemLayoutSizeFitting(CGSize(width: tableViewManager.tableView.frame.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        return height
    }
    
    public func map<T: JRTableViewItem>(_ type: T.Type) -> T {
        self as! T
    }
    
    public func setupConfig() {}
    
    public func calculate() {}
}

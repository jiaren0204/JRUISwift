import UIKit

public typealias JRTableViewSectionBlock = (JRTableViewSection) -> Void

open class JRTableViewSection: NSObject {
    public weak var tableViewManager: JRTableViewManager!
    public var items = [JRTableViewItem]()

    public var headerItem: JRTableViewHeaderFooterItem?
    public var footerItem: JRTableViewHeaderFooterItem?

    var headerWillDisplayHandler: JRTableViewSectionBlock?
    public func setHeaderWillDisplayHandler(_ block: JRTableViewSectionBlock?) {
        headerWillDisplayHandler = block
    }

    var headerDidEndDisplayHandler: JRTableViewSectionBlock?
    public func setHeaderDidEndDisplayHandler(_ block: JRTableViewSectionBlock?) {
        headerDidEndDisplayHandler = block
    }

    public var index: Int {
        let section = tableViewManager.sections.firstIndex(where: { (section) -> Bool in
            section == self
        })
        return section!
    }

    public override init() {
        super.init()
        items = []
    }

    public convenience init(headerItem: JRTableViewHeaderFooterItem? = nil, footerItem: JRTableViewHeaderFooterItem? = nil) {
        self.init()

        if let headerItem = headerItem {
            headerItem.tableViewManager = tableViewManager;
            headerItem.section = self
        }
        
        if let footerItem = footerItem {
            footerItem.tableViewManager = tableViewManager;
            footerItem.section = self
        }
    }

    public func add(item: JRTableViewItem) {
        item.section = self
        item.tableViewManager = tableViewManager
        items.append(item)
    }

    public func remove(item: JRTableViewItem) {
        if let index = items.firstIndex(where: { $0 == item }) {
            items.remove(at: index)
        } else {
            print("item not in this section")
        }
    }

    public func removeAllItems() {
        items.removeAll()
    }

    public func replaceItemsFrom(array: [JRTableViewItem]!) {
        removeAllItems()
        items = items + array
    }

    public func insert(_ item: JRTableViewItem!, afterItem: JRTableViewItem, animation: UITableView.RowAnimation = .automatic) {
        if !items.contains(where: { $0 == afterItem }) {
            print("can't insert because afterItem did not in sections")
            return
        }
        
        tableViewManager.tableView.beginUpdates()
        item.section = self
        item.tableViewManager = tableViewManager
        items.insert(item, at: items.firstIndex(where: { $0 == afterItem })! + 1)
        tableViewManager.tableView.insertRows(at: [item.indexPath], with: animation)
        tableViewManager.tableView.endUpdates()
    }

    public func insert(_ items: [JRTableViewItem], afterItem: JRTableViewItem, animation: UITableView.RowAnimation = .automatic) {
        if !self.items.contains(where: { $0 == afterItem }) {
            print("can't insert because afterItem did not in sections")
            return
        }

        tableViewManager.tableView.beginUpdates()
        let newFirstIndex = self.items.firstIndex(where: { $0 == afterItem })! + 1
        self.items.insert(contentsOf: items, at: newFirstIndex)
        var arrNewIndexPath = [IndexPath]()
        for i in 0 ..< items.count {
            items[i].section = self
            items[i].tableViewManager = tableViewManager
            arrNewIndexPath.append(IndexPath(item: newFirstIndex + i, section: afterItem.indexPath.section))
        }
        tableViewManager.tableView.insertRows(at: arrNewIndexPath, with: animation)
        tableViewManager.tableView.endUpdates()
    }

    public func delete(_ itemsToDelete: [JRTableViewItem], animation: UITableView.RowAnimation = .automatic) {
        guard itemsToDelete.count > 0 else { return }
        tableViewManager.tableView.beginUpdates()
        var arrNewIndexPath = [IndexPath]()
        for i in itemsToDelete {
            arrNewIndexPath.append(i.indexPath)
        }
        for i in itemsToDelete {
            remove(item: i)
        }
        tableViewManager.tableView.deleteRows(at: arrNewIndexPath, with: animation)
        tableViewManager.tableView.endUpdates()
    }
    
    public func getAllCellHeight() -> CGFloat {
        var height: CGFloat = 0
        for item in self.items {
            height += item.cellHeight
        }
        
        if let headerItem = self.headerItem {
            height += headerItem.height
        }
        
        if let footerItem = self.footerItem {
            height += footerItem.height
        }
        return height
    }

    public func reload(_ animation: UITableView.RowAnimation) {
        if let index = tableViewManager.sections.firstIndex(where: { $0 == self }) {
            tableViewManager.tableView.reloadSections(IndexSet(integer: index), with: animation)
        } else {
            print("section did not in manager！")
        }
    }
    
    public func reload(items: [JRTableViewItem], animation: UITableView.RowAnimation) {
        if let _ = tableViewManager.sections.firstIndex(where: { $0 == self }) {
            for item in items {
                item.reload(animation)
            }
        } else {
            print("section did not in manager！")
        }
    }
}

import UIKit
@objc public protocol JRTableViewDelegate: NSObjectProtocol {
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public protocol TableEvent {
    func getName() -> String
}

open class JRTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    public weak var delegate: JRTableViewDelegate?
    public var tableView: UITableView!
    public var sections: [JRTableViewSection] = []
    var defaultTableViewSectionHeight: CGFloat {
        return tableView.style == .grouped ? 44 : 0
    }
    
    private var cellEventDic = [String: (JRTableViewItem, Any?) -> (Void)]()
    private var headerFooterEventDic = [String: (JRTableViewHeaderFooterItem, Any?) -> (Void)]()
    
    public init(tableView: UITableView, cellClasses: [AnyClass]? = nil, headerFooterClasses: [AnyClass]? = nil) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        
        if let cellClasses = cellClasses {
            for cellClass in cellClasses {
                registerCell(cellClass)
            }
        }
        
        if let headerFooterClasses = headerFooterClasses {
            for headerFooterClass in headerFooterClasses {
                registerHeadFooter(headerFooterClass)
            }
        }
    }
    
    /// use this method to update cell height after you change item.cellHeight.
    open func updateHeight() {
        tableView.performBatchUpdates({
            
        }) { [weak self] (finish) in
            if finish {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func registerCell(_ cellClass: AnyClass) {
        guard let cellName = NSStringFromClass(cellClass).components(separatedBy: ".").last else {
            return
        }
        
        if Bundle.main.path(forResource: "\(cellClass)", ofType: "nib") != nil {
            tableView.register(UINib(nibName: "\(cellClass)", bundle: Bundle.main), forCellReuseIdentifier: cellName)
        } else {
            tableView.register(cellClass, forCellReuseIdentifier: cellName)
        }
    }
    
    private func registerHeadFooter(_ headerFooterClass: AnyClass) {
        guard let headerFooterName = NSStringFromClass(headerFooterClass).components(separatedBy: ".").last else {
            return
        }
        
        if Bundle.main.path(forResource: "\(headerFooterClass)", ofType: "nib") != nil {
            tableView.register(UINib(nibName: "\(headerFooterClass)", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: headerFooterName)
        } else {
            tableView.register(headerFooterClass, forHeaderFooterViewReuseIdentifier: headerFooterName)
        }
    }
    
    public func getAllCellHeight() -> CGFloat {
        var height = CGFloat(0)
        for section in self.sections {
            height += section.getAllCellHeight()
        }
        return height
    }
    
    public func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let curSection = sections[section]
        if let headerItem = curSection.headerItem {
            return headerItem.height
        }
        
        return 0
    }
    
    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let curSection = sections[section]
        guard let headerItem = curSection.headerItem else {
            return nil
        }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerItem.cellIdentifier) as! JRTableViewHeaderFooterView
        view.item = headerItem
        
        return view
    }
    
    public func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let curSection = sections[section]
        if let footerItem = curSection.footerItem {
            return footerItem.height
        }
        
        return 0
    }
    
    public func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let curSection = sections[section]
        guard let footerItem = curSection.footerItem else {
            return nil
        }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerItem.cellIdentifier) as! JRTableViewHeaderFooterView
        view.item = footerItem
        
        return view
    }
    
    
    public func tableView(_: UITableView, willDisplayHeaderView _: UIView, forSection section: Int) {
        let (currentSection, _) = sectinAndItemFrom(indexPath: nil, sectionIndex: section, rowIndex: nil)
        currentSection?.headerWillDisplayHandler?(currentSection!)
    }
    
    public func tableView(_: UITableView, didEndDisplayingHeaderView _: UIView, forSection section: Int) {
        let (currentSection, _) = sectinAndItemFrom(indexPath: nil, sectionIndex: section, rowIndex: nil)
        currentSection?.headerDidEndDisplayHandler?(currentSection!)
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = sections[section]
        return currentSection.items.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentSection = sections[indexPath.section]
        let item = currentSection.items[indexPath.row]

        return item.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = sections[indexPath.section]
        let item = currentSection.items[indexPath.row]
        item.tableViewManager = self
        // 报错在这里，可能是是没有register cell
        var cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier) as? JRTableViewCell
        
        if cell == nil {
            cell = JRTableViewCell(style: item.cellStyle, reuseIdentifier: item.cellIdentifier)
        }

        cell?.selectionStyle = item.selectionStyle
        
        cell?.item = item
        cell?.update()
        
        return cell!
    }
    
    public func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        (cell as! JRTableViewCell).didDisappear()
    }
    
    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        (cell as! JRTableViewCell).didAppear()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = sections[indexPath.section]
        let item = currentSection.items[indexPath.row]
        if item.isAutoDeselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! JRTableViewCell
        cell.didSelect()
    }
    
    public func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let (_, item) = sectinAndItemFrom(indexPath: indexPath, sectionIndex: nil, rowIndex: nil)
        return item!.editingStyle
    }
    
    public func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let (_, item) = sectinAndItemFrom(indexPath: indexPath, sectionIndex: nil, rowIndex: nil)
        
        if editingStyle == .delete {
            if let handler = item?.deletionHandler {
                handler(item!)
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let d = delegate {
            if d.responds(to: #selector(JRTableViewDelegate.scrollViewDidScroll(_:))) {
                d.scrollViewDidScroll(scrollView)
            }
        }
    }
    
    func sectinAndItemFrom(indexPath: IndexPath?, sectionIndex: Int?, rowIndex: Int?) -> (JRTableViewSection?, JRTableViewItem?) {
        var currentSection: JRTableViewSection?
        var item: JRTableViewItem?
        if let idx = indexPath {
            currentSection = sections[idx.section]
            item = currentSection?.items[idx.row]
        }
        
        if let idx = sectionIndex {
            currentSection = sections.count > idx ? sections[idx] : nil
        }
        
        if let idx = rowIndex {
            item = (currentSection?.items.count)! > idx ? currentSection?.items[idx] : nil
        }
        
        return (currentSection, item)
    }
    
    public func add(section: JRTableViewSection) {
        if !section.isKind(of: JRTableViewSection.self) {
            print("error section class")
            return
        }
        section.tableViewManager = self
        sections.append(section)
    }
    
    public func remove(section: Any) {
        if !(section as AnyObject).isKind(of: JRTableViewSection.self) {
            print("error section class")
            return
        }
        sections.remove(at: sections.firstIndex(where: { (current) -> Bool in
            current == (section as! JRTableViewSection)
        })!)
    }
    
    public func removeAllSections() {
        sections.removeAll()
    }
    
    public func reload() {
        tableView.reloadData()
    }
    
    
    public func registerCellEvent(_ event: TableEvent, callback: @escaping (JRTableViewItem, Any?)->(Void)) {
        cellEventDic[event.getName()] = callback
    }
    
    public func performCellEvent(_ event: TableEvent, item: JRTableViewItem, msg: Any? = nil) {
        cellEventDic[event.getName()]?(item, msg)
    }
    
    public func registerHeaderFooterEvent(_ event: TableEvent, callback: @escaping (JRTableViewHeaderFooterItem, Any?)->(Void)) {
        headerFooterEventDic[event.getName()] = callback
    }
    
    public func performHeaderFooterEvent(_ event: TableEvent, item: JRTableViewHeaderFooterItem, msg: Any? = nil) {
        headerFooterEventDic[event.getName()]?(item, msg)
    }
}

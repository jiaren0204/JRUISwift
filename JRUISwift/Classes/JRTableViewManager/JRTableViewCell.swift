import UIKit

open class JRTableViewCell: UITableViewCell {
//    public var cellItem: JRTableViewItem!

    open override func awakeFromNib() {
        super.awakeFromNib()
        defaultSet()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        defaultSet()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func defaultSet() {
        backgroundColor = .clear
        clipsToBounds = true
    }

    open func setupConfig() { }

    open func update() {}

    open func didAppear() {}

    open func didDisappear() {}
    
    open func didSelect() {}
    
    open func didHighlight() {}

    open func didUnhighlight() {}
    
//    open func performCellEvent(_ event: JRTableViewEvent, msg: Any? = nil) {
//        cellItem.tableViewManager.performCellEvent(event, item: cellItem, msg: msg)
//    }
}

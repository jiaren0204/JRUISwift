import UIKit

open class JRTableViewCell: UITableViewCell {
    public var item: JRTableViewItem!

    open override func awakeFromNib() {
        super.awakeFromNib()
        defaultSet()
        setupConfig()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        defaultSet()
        setupConfig()
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
    
    open func performCellEvent(_ event: TableEvent, msg: Any? = nil) {
        item.tableViewManager.performCellEvent(event, item: item, msg: msg)
    }
}

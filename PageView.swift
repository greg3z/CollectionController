//
//  PageView.swift
//  ListsView
//
//  Created by Grégoire Lhotellier on 12/01/2016.
//  Copyright © 2016 Kawet. All rights reserved.
//

import UIKit

final class PageView<Element>: UITableViewController {
    
    var page: Page<Element> {
        didSet {
            refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    var refreshCallback: (Void -> Void)? {
        didSet {
            setRefreshControl()
        }
    }
    var elementTouched: ((Element, UITableViewCell) -> Void)?
    var editActions: (Element -> [EditAction])?
    var elementAction: ((Element, String) -> Void)?
    var configureCell: ((Element, cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) -> Void)?
    let cellType: (Element -> UITableViewCell.Type)?
    
    init(page: Page<Element>, style: UITableViewStyle = .Plain, cellType: (Element -> UITableViewCell.Type)? = nil) {
        self.page = page
        self.cellType = cellType
        super.init(style: style)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 90
        tableView.tableFooterView = UIView()
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        setRefreshControl()
    }
    
    func setRefreshControl() {
        if isViewLoaded() && refreshCallback != nil {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        }
    }
    
    func refresh() {
        refreshCallback?()
    }
    
    func reloadVisibleCells() {
        if isViewLoaded() {
            tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows ?? [], withRowAnimation: .None)
        }
    }
    
    // UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return page.sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page.sections[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return page.sections[section].title
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let element = page[indexPath] else {
            return UITableViewCell()
        }
        let cellClass = cellType?(element) ?? UITableViewCell.self
        let cellId = "\(cellClass)"
        tableView.registerClass(cellClass, forCellReuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        configureCell?(element, cell: cell, tableView: tableView, indexPath: indexPath)
        return cell
    }
    
    // UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let element = page[indexPath], cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }
        elementTouched?(element, cell)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        guard let element = page[indexPath] else {
            return []
        }
        var rowActions = [UITableViewRowAction]()
        for editAction in editActions?(element) ?? [] {
            let rowAction = UITableViewRowAction(style: editAction.style, title: editAction.title) {
                [weak self] _, indexPath in
                tableView.setEditing(false, animated: true)
                self?.elementAction?(element, editAction.title)
            }
            rowActions.append(rowAction)
        }
        return rowActions
    }
    
}

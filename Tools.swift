//
//  ElementListable.swift
//  ListView
//
//  Created by Grégoire Lhotellier on 10/02/2016.
//  Copyright © 2016 Grégoire Lhotellier. All rights reserved.
//

import Foundation
import UIKit

protocol ElementListable: Hashable {
    
    func cellType(context: CellTypeContext?) -> UITableViewCell.Type
    func configureCell(cell: UITableViewCell, context: CellTypeContext?)
    func editActions() -> [EditAction]
    
}

extension ElementListable {
    
    func cellType(context: CellTypeContext?) -> UITableViewCell.Type {
        return UITableViewCell.self
    }
    
    func editActions() -> [EditAction] {
        return []
    }
    
}

protocol CellTypeContext {
    
}

struct EditAction {
    
    let title: String
    let style: UITableViewRowActionStyle
    
}

extension Page {
    
    subscript(indexPath: NSIndexPath) -> Element? {
        let index = PageIndex(sectionsSize: [], currentIndex: (section: indexPath.section, element: indexPath.row))
        return self[safe: index]
    }
    
}

extension PageIndex {
    
    var indexPath: NSIndexPath {
        return NSIndexPath(forRow: currentIndex.element, inSection: currentIndex.section)
    }
    
    init(indexPath: NSIndexPath) {
        self.init(sectionsSize: [], currentIndex: (section: indexPath.section, element: indexPath.row))
    }
    
}

enum TickStyle {
    case None, Single, Multiple
}

extension CollectionType where Generator.Element: Equatable {
    
    func indexesOf(searchedElement: Generator.Element) -> [Index] {
        var indexes = [Index]()
        var index = startIndex
        while index != endIndex {
            let element = self[index]
            if element == searchedElement {
                indexes.append(index)
            }
            index = index.successor()
        }
        return indexes
    }
    
}

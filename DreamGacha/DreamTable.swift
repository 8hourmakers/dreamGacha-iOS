//
//  DreamTable.swift
//  DreamGacha
//
//  Created by Noverish Harold on 2017. 8. 27..
//  Copyright © 2017년 8hourmakers. All rights reserved.
//

import UIKit

class DreamTable: InfiniteTableView, InfiniteTableViewDataSource, InfiniteTableViewDelegate {

    var selectedItems:[DreamItem] {
        get {
            return items.map { $0 as! DreamItem }.filter{ $0.isSelected }
        }
    }

    func initiate(vc: UIViewController) {
        super.collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: CGFloat(10), right: CGFloat(10))
        super.collectionViewFlowLayout.minimumLineSpacing = CGFloat(5)
        super.initiate(nibName: String(describing: DreamCell.self), dataSource: self)
    }

    func infiniteTableView(_ infiniteTableView: InfiniteTableView, itemsOn page: Int, callback: @escaping ([Any]) -> Void) {
        if(page == 1) {
            ServerClient.getDreamList(lastDreamId: nil) { newItems in
                callback(newItems)
            }
        } else {
            callback([])
        }
    }

    func infiniteTableView(_ infiniteTableView: InfiniteTableView, set cell: UICollectionViewCell, for item: Any) -> UICollectionViewCell {
        if let cell = cell as? DreamCell,
           let item = item as? DreamItem {
            cell.setItem(item)
        }

        return cell
    }

    func infiniteTableView(_ infiniteTableView: InfiniteTableView, item lhs: Any, isEqualTo rhs: Any) -> Bool {
        if let lhs = lhs as? DreamItem,
           let rhs = rhs as? DreamItem {
            return lhs.id == rhs.id
        }

        return false
    }

    @objc func infiniteTableView(_ infiniteTableView: InfiniteTableView, cellHeightOf item: Any, cellWidth: CGFloat) -> CGFloat {
        return CGFloat(110)
    }
    
    func selectAllClicked() {
        let isAllSelected = items.reduce(true) {
            $0 && ($1 as! DreamItem).isSelected
        }

        for item in items {
            if let item = item as? DreamItem {
                item.isSelected = !isAllSelected
            }
        }

        if(isAllSelected) {
            EventBus.post(event: .dreamCellDeselectAll)
        } else {
            EventBus.post(event: .dreamCellSelectAll)
        }
    }
}

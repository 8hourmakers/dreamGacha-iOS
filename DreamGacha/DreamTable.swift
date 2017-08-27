//
//  DreamTable.swift
//  DreamGacha
//
//  Created by Noverish Harold on 2017. 8. 27..
//  Copyright © 2017년 8hourmakers. All rights reserved.
//

import UIKit

class DreamTable: PagingTableView, PagingTableViewDataSource, PagingTableViewDelegate {

    var selectedItems:[DreamItem] = []

    var selectAllMode = false

    func initiate(vc: UIViewController) {
        super.initialize(nowVC: vc, dataSource: self)
        super.sectionInset = CGFloat(10)
        super.itemSpacing = CGFloat(5)

        EventBus.register(self, event: .dreamCellSelected, action: #selector(self.dreamCellSelected))
        EventBus.register(self, event: .dreamCellDeselected, action: #selector(self.dreamCellDeselected))
    }
    
    func getNibName() -> String {
        return "DreamCell"
    }

    func loadMoreItems(page: Int, callback: @escaping ([Any]) -> Void) {
        ServerClient.getDreamList(lastDreamId: nil) { newItems in
            callback(newItems)
        }
    }

    func setItem(cell: UICollectionViewCell, item: Any) -> UICollectionViewCell {
        if let cell = cell as? DreamCell,
           let item = item as? DreamItem {
            cell.setItem(item, selected: selectAllMode)
        }

        return cell
    }

    func calcHeight(width: CGFloat, item: Any) -> CGFloat {
        return CGFloat(110)
    }

    func dreamCellSelected(_ notification: Notification) {
        guard let item = notification.object as? DreamItem else {
            return
        }

        selectedItems.append(item)
    }

    func dreamCellDeselected(_ notification: Notification) {
        guard let item = notification.object as? DreamItem else {
            return
        }

        selectedItems = selectedItems.filter { $0 !== item }
    }

    func selectAllDreamCells() {
        selectedItems.removeAll()
        selectedItems.append(contentsOf: items.map{ $0 as! DreamItem })

        for cell in collectionView.visibleCells {
            if let cell = cell as? DreamCell {
                cell.enableRadio()
            }
        }
    }

    func deselectAllDreamCells() {
        selectedItems.removeAll()

        for cell in collectionView.visibleCells {
            if let cell = cell as? DreamCell {
                cell.disableRadio()
            }
        }
    }
}

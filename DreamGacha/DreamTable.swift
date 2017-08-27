//
//  DreamTable.swift
//  DreamGacha
//
//  Created by Noverish Harold on 2017. 8. 27..
//  Copyright © 2017년 8hourmakers. All rights reserved.
//

import UIKit

class DreamTable: PagingTableView, PagingTableViewDataSource, PagingTableViewDelegate {

    func initiate(vc: UIViewController) {
        super.initialize(nowVC: vc, dataSource: self)
        super.sectionInset = CGFloat(10)
        super.itemSpacing = CGFloat(5)
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
            cell.setItem(item)
        }

        return cell
    }

    func calcHeight(width: CGFloat, item: Any) -> CGFloat {
        return CGFloat(110)
    }
}

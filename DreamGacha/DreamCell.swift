//
// Created by Noverish Harold on 2017. 8. 27..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import UIKit

class DreamCell: UICollectionViewCell {

    var item: DreamItem? = nil

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        bg.setRadius(10)
    }

    func setItem(_ item: DreamItem) {
        self.item = item

        self.date.text = item.createDate
        self.title.text = item.title
        self.content.text = item.content
    }
}

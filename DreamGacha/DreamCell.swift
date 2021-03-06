//
// Created by Noverish Harold on 2017. 8. 27..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import UIKit

class DreamCell: UICollectionViewCell {

    var item: DreamItem!

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var radioBtn: UIButton!
    
    var isRadioOn = false

    override func layoutSubviews() {
        super.layoutSubviews()
        
        bg.setRadius(10)

        EventBus.register(self, event: .deleteModeEnabled, action: #selector(self.deleteModeEnabled))
        EventBus.register(self, event: .deleteModeDisabled, action: #selector(self.deleteModeDisabled))
        EventBus.register(self, event: .dreamCellSelectAll, action: #selector(self.enableRadio))
        EventBus.register(self, event: .dreamCellDeselectAll, action: #selector(self.disableRadio))
    }

    func setItem(_ item: DreamItem) {
        self.item = item

        self.dateLabel.text = item.createDate
        self.titleLabel.text = item.title
        self.contentLabel.text = item.content

        if(MainVC.isDeleteMode) {
            self.deleteModeEnabled()
        }
        
        if(item.isSelected) {
            self.enableRadio()
        } else {
            self.disableRadio()
        }
    }
    
    @IBAction func radioBtnClicked(_ sender: Any) {
        self.isRadioOn = !isRadioOn
        
        if(isRadioOn) {
            enableRadio()
            EventBus.post(event: .dreamCellSelected, data: item)
        } else {
            disableRadio()
            EventBus.post(event: .dreamCellDeselected, data: item)
        }
    }

    func deleteModeEnabled() {
        dateLabelLeading.constant = 70

        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
            self.radioBtn.alpha = 1
        })
    }

    func deleteModeDisabled() {
        dateLabelLeading.constant = 20

        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
            self.radioBtn.alpha = 0
        })
    }

    func enableRadio() {
        item.isSelected = true
        radioBtn.setImage(UIImage(named: "radioOn1"), for: .normal)
    }

    func disableRadio() {
        item.isSelected = false
        radioBtn.setImage(UIImage(named: "radioOff1"), for: .normal)
    }
}

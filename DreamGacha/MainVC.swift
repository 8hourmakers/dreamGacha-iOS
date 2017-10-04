//
// Created by Noverish Harold on 2017. 8. 13..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet weak var dreamTable: DreamTable!
    @IBOutlet weak var deleteNavBar: UINavigationBar!
    @IBOutlet weak var deleteNavBarBtn2: UIBarButtonItem!

    static var isDeleteMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        dreamTable.initiate(vc: self)

        EventBus.register(self, event: .deleteModeEnabled, action: #selector(self.deleteModeEnabled))
        EventBus.register(self, event: .deleteModeDisabled, action: #selector(self.deleteModeDisabled))
        EventBus.register(self, event: .dreamCellSelected, action: #selector(self.dreamCellSelectionChanged))
        EventBus.register(self, event: .dreamCellDeselected, action: #selector(self.dreamCellSelectionChanged))
        EventBus.register(self, event: .dreamCreated, action: #selector(self.dreamCreated))
    }

    @IBAction func deleteClicked() {
        MainVC.isDeleteMode = true
        EventBus.post(event: .deleteModeEnabled)
    }

    @IBAction func selectAllClicked() {
        dreamTable.selectAllClicked()
    }

    @IBAction func deleteDreamClicked() {
        if(dreamTable.selectedItems.count == 0) {
            MainVC.isDeleteMode = false
            EventBus.post(event: .deleteModeDisabled)
        } else {
            for item in dreamTable.selectedItems {
                ServerClient.deleteDream(dreamId: item.id) {
                    DispatchQueue.main.async {
                        self.dreamTable.deleteItem(item)
                        self.dreamCellSelectionChanged()
                    }
                }
            }
        }
    }

    @IBAction func recordClicked() {
        performSegue(withIdentifier: "segRecord", sender: nil)
    }

    func deleteModeEnabled() {
        UIView.animate(withDuration: 0.4, animations: {
            self.deleteNavBar.alpha = 1
        })
    }

    func deleteModeDisabled() {
        UIView.animate(withDuration: 0.4, animations: {
            self.deleteNavBar.alpha = 0
        })
    }

    func dreamCellSelectionChanged() {
        if(dreamTable.selectedItems.count == 0) {
            self.deleteNavBarBtn2.title = "취소하기"
        } else {
            self.deleteNavBarBtn2.title = "삭제하기"
        }
    }
    
    func dreamCreated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.dreamTable.refresh()
        }
    }
}

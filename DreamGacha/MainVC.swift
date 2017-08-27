//
// Created by Noverish Harold on 2017. 8. 13..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet weak var dreamTable: DreamTable!

    override func viewDidLoad() {
        super.viewDidLoad()

        dreamTable.initiate(vc: self)
    }
}

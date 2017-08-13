//
//  RecordVC.swift
//  DreamGacha
//
//  Created by Noverish Harold on 2017. 8. 13..
//  Copyright © 2017년 8hourmakers. All rights reserved.
//

import UIKit
import HGCircularSlider

class RecordVC: UIViewController {
    
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var circleProgress: CircularSlider!
    @IBOutlet weak var circleProgressDisk: UIView!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var recordedTime: UILabel!
    
    var endPointValue = CGFloat(0)
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bg.setGradient(colors: [UIColor(rgbString: "#700082"), UIColor(rgbString: "#19134d")])

        circleProgressDisk.layer.cornerRadius = circleProgressDisk.frame.size.width/2
        circleProgressDisk.clipsToBounds = true
    }

    @IBAction func recordClicked() {
        if isRecording {
            isRecording = false
        } else {
            isRecording = true
            endPointValue = 0
            startRecord()
        }
    }
    
    func startRecord() {
        if endPointValue >= 60 {
            return
        }
        
        if !isRecording {
            return
        }
        
        circleProgress.endPointValue = endPointValue
        endPointValue += 0.1
        recordedTime.text = String(format: "%2.2f", endPointValue)
        remainingTime.text = String(format: "%2.2f", 60 - endPointValue)
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startRecord()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
}

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

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var circleProgress: CircularSlider!
    @IBOutlet weak var circleProgressDisk: UIView!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var recordedTime: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!

    var endPointValue = CGFloat(0)
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bg.setGradient(colors: [UIColor(rgbString: "#700082"), UIColor(rgbString: "#19134d")])

        circleProgressDisk.layer.cornerRadius = circleProgressDisk.frame.size.width/2
        circleProgressDisk.clipsToBounds = true

        circleProgress.endPointValue = 0

        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
    }

    @IBAction func recordClicked() {
        playBtn.isHidden = false
        saveBtn.isHidden = false

        if isRecording {
            isRecording = false
            recordBtn.setImage(UIImage(named: "btnRecordStart"), for: .normal)
            playBtn.setImage(UIImage(named: "btnRecordPlayOn"), for: .normal)
            saveBtn.setImage(UIImage(named: "btnRecordSaveOn"), for: .normal)
            playBtn.isEnabled = true
            saveBtn.isEnabled = true
        } else {
            isRecording = true
            recordBtn.setImage(UIImage(named: "btnRecordPause"), for: .normal)
            playBtn.setImage(UIImage(named: "btnRecordPlayOff"), for: .normal)
            saveBtn.setImage(UIImage(named: "btnRecordSaveOff"), for: .normal)
            playBtn.isEnabled = false
            saveBtn.isEnabled = false
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

    @IBAction func backClicked() {
        self.dismiss(animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
}

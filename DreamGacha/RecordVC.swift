//
//  RecordVC.swift
//  DreamGacha
//
//  Created by Noverish Harold on 2017. 8. 13..
//  Copyright © 2017년 8hourmakers. All rights reserved.
//

import UIKit
import HGCircularSlider
import AVFoundation

class RecordVC: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

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
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder!

    var endPointValue = CGFloat(0)
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        bg.setGradient(colors: [UIColor(rgbString: "#700082"), UIColor(rgbString: "#19134d")])

        circleProgressDisk.layer.cornerRadius = circleProgressDisk.frame.size.width/2
        circleProgressDisk.clipsToBounds = true

        circleProgress.endPointValue = 0

        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
        
        
        
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.wav")
        
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVFormatIDKey: kAudioFormatLinearPCM,
             AVEncoderBitRateKey: 16000,
             AVNumberOfChannelsKey: 1,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }

    @IBAction func recordClicked() {
        playBtn.isHidden = false
        saveBtn.isHidden = false

        if isRecording {
            stopRecord()
        } else {
            startRecord()
        }
    }
    
    @IBAction func playClicked() {
        if(audioRecorder.isRecording) {
            return
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch let error as NSError {
            print("audioPlayer error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func saveClicked() {
        let alert = UIAlertController(title: "꿈 제목", message: "꿈 제목을 입력해주세요", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "title" }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let title = alert?.textFields?[0].text else {
                return
            }
            
            do {
                let audio = try Data(contentsOf: self.audioRecorder.url)
                
                ServerClient.sendWavFile(wavFile: audio) { (dreamAudioItem) in
                    ServerClient.makeDream(dreamAudioItem: dreamAudioItem, title: title) { (dreamItem) in
                        EventBus.post(event: .dreamCreated, data: dreamItem)
                        self.dismiss(animated: true)
                    }
                }
            } catch let error {
                print("audioPlayer error: \(error.localizedDescription)")
                return
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func startRecord() {
        if(audioRecorder.isRecording) {
            return
        }
        
        isRecording = true
        recordBtn.setImage(UIImage(named: "btnRecordPause"), for: .normal)
        playBtn.setImage(UIImage(named: "btnRecordPlayOff"), for: .normal)
        saveBtn.setImage(UIImage(named: "btnRecordSaveOff"), for: .normal)
        playBtn.isEnabled = false
        saveBtn.isEnabled = false
        progressTimeBar()
        audioRecorder.record()
    }
    
    private func stopRecord() {
        isRecording = false
        recordBtn.setImage(UIImage(named: "btnRecordStart"), for: .normal)
        playBtn.setImage(UIImage(named: "btnRecordPlayOn"), for: .normal)
        saveBtn.setImage(UIImage(named: "btnRecordSaveOn"), for: .normal)
        playBtn.isEnabled = true
        saveBtn.isEnabled = true
        
        if(audioRecorder.isRecording) {
            audioRecorder.stop()
        } else {
            audioPlayer?.stop()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur")
    }
    
    func progressTimeBar() {
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
            self.progressTimeBar()
        }
    }

    @IBAction func backClicked() {
        self.dismiss(animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
}

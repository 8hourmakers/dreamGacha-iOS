//
// Created by Noverish Harold on 2017. 8. 13..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import UIKit
import Gifu

class LoginVC: UIViewController {

    let loginAppLogoWidth = CGFloat(120)
    let loginAppLogoHeight = CGFloat(143)
    let loginAppLogoTop = CGFloat(101)

    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var appLogoWidth: NSLayoutConstraint!
    @IBOutlet weak var appLogoHeight: NSLayoutConstraint!
    @IBOutlet weak var appLogoTop: NSLayoutConstraint!
    @IBOutlet weak var splash: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gifImageView: GIFImageView!
    var mIsKeyboardShown = false

    override func viewDidLoad() {
        gifImageView.animate(withGIFNamed: "LoginVideo")

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.hideSplash()
        }
    }

    func hideSplash() {
        appLogoWidth.constant = loginAppLogoWidth
        appLogoHeight.constant = loginAppLogoHeight
        appLogoTop.constant = loginAppLogoTop

        UIView.animate(
                withDuration: 0.4,
                animations: {
                    self.splash.alpha = 0

                    self.view.layoutIfNeeded()
                },
                completion: { success in
                    self.splash.isHidden = true
                    self.appLogo.isHidden = true
                    self.scrollView.isHidden = false
                })
    }

    @IBAction func loginClicked() {

    }

    @IBAction func signUpClicked() {

    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if !mIsKeyboardShown {
                mIsKeyboardShown = true

                var contentInset:UIEdgeInsets = self.scrollView.contentInset
                contentInset.bottom = keyboardSize.height
                scrollView.contentInset = contentInset
                scrollView.contentOffset.y = keyboardSize.height

                self.view.layoutIfNeeded()
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if mIsKeyboardShown {
                mIsKeyboardShown = false

                var contentInset:UIEdgeInsets = self.scrollView.contentInset
                contentInset.bottom = 0
                scrollView.contentInset = contentInset
                scrollView.contentOffset.y = 0

                self.view.layoutIfNeeded()
            }
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}

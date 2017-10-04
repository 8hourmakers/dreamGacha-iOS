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
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var mIsKeyboardShown = false
    var mIsLoginMode = true

    override func viewDidLoad() {
        gifImageView.animate(withGIFNamed: "LoginVideo")

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        if let email = UserDefaults.standard.string(forKey: ServerClient.USER_DEFAULT_EMAIL),
           let password = UserDefaults.standard.string(forKey: ServerClient.USER_DEFAULT_PASSWORD) {
            ServerClient.login(email: email, password: password) { (msg) in
                DispatchQueue.main.async {
                    self.processLogin(loginSuccess: msg == nil, loginFailMsg: msg)
                }
            }
        } else {
            self.processLogin(loginSuccess: false, loginFailMsg: nil)
        }
    }
    
    private func processLogin(loginSuccess: Bool, loginFailMsg: String?) {
        if(loginSuccess) {
            self.performSegue(withIdentifier: "segMain", sender: nil)
        } else {
            if let msg = loginFailMsg {
                self.showToast(msg)
            }
            
            hideSplash()
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
        ServerClient.login(
                email: emailField.text ?? "",
                password: passwordField.text ?? "") { (msg) in
            DispatchQueue.main.async {
                guard let msg = msg else {
                    self.performSegue(withIdentifier: "segMain", sender: nil)
                    return
                }

                self.showToast(msg)
            }
        }
    }

    @IBAction func signUpClicked() {
        ServerClient.register(
                email: emailField.text ?? "",
                password: passwordField.text ?? "") { (msg) in
            DispatchQueue.main.async {
                guard let msg = msg else {
                    self.performSegue(withIdentifier: "segMain", sender: nil)
                    return
                }

                self.showToast(msg)
            }
        }
    }

    @IBAction func createAccountClicked() {
        mIsLoginMode = !mIsLoginMode

        UIView.animate(
                withDuration: 0.4,
                animations: {
                    self.loginBtn.alpha = (self.mIsLoginMode) ? 1 : 0
                    self.registerBtn.alpha = (self.mIsLoginMode) ? 0 : 1
                }, completion: { success in

                }
        )
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
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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

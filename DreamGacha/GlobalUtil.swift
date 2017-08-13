//
//  GlobalUtil.swift
//  DreamGacha
//
//  Created by Noverish Harold on 2017. 8. 13..
//  Copyright © 2017년 8hourmakers. All rights reserved.
//

import Foundation
import UIKit

extension String {
    @discardableResult
    mutating func removeLastChar() -> String {
        self = self.substring(to: self.index(before: self.endIndex))
        return self
    }
}

extension HTTPURLResponse {
    func isSuccess() -> Bool {
        return (200 ... 299).contains(self.statusCode)
    }
}

extension UIView {
    func setShadow(radius:Int = 1,
                   color:UIColor = UIColor.black,
                   offset:CGSize = CGSize.zero,
                   opacity:Float = 0.5) {
        
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
    }
    
    /*
     func addShadow() {
     self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.3).cgColor
     self.layer.shadowOpacity = 1
     self.layer.shadowOffset = CGSize.zero
     self.layer.shadowRadius = 2
     }
     */
    
    func setBorder(width: CGFloat = 1,
                   color: UIColor = UIColor.black) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func setGradient(colors:[UIColor] = [UIColor.white, UIColor.black],
                     startPoint: CGPoint = CGPoint(0, 0),
                     endPoint: CGPoint = CGPoint(1, 1),
                     cornerRadius: CGFloat = 0) {
        
        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.frame = self.bounds
        gradientLayer1.colors = colors.map { $0.cgColor }
        gradientLayer1.cornerRadius = cornerRadius
        gradientLayer1.startPoint = startPoint
        gradientLayer1.endPoint = endPoint
        
        self.layer.addSublayer(gradientLayer1)
    }
    
    func updateLayers() {
        self.layer.sublayers?.forEach {
            $0.frame = self.frame
        }
    }
}

extension UIViewController {
    func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    func hideKeyboard() {
        self.view.endEditing(true)
    }

    func showAlertView(title: String,
                       msg: String,
                       preferredStyle: UIAlertControllerStyle = .alert,
                       actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: preferredStyle)

        for action in actions {
            alert.addAction(action)
        }

        self.present(alert, animated: true, completion: nil)
    }
}

//https://stackoverflow.com/a/43664156
extension Date {
    func isInSameDay(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    func isInSameWeek(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInSameYear(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    var isInThisWeek: Bool {
        return isInSameWeek(Date())
    }
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a:Int = 255) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
    
    convenience init(argb: Int) {
        var alpha:Int = argb >> 24
        if alpha == 0 {
            alpha = 255
        }

        self.init(
            r: (argb >> 16) & 0xFF,
            g: (argb >> 8) & 0xFF,
            b: argb & 0xFF,
            a: alpha
        )
    }

    convenience init(rgbString: String) {
        let rgbString = rgbString.replacingOccurrences(of: "#", with: "")
        let rgb = Int(rgbString, radix:16)!

        self.init(argb: rgb)
    }
    
    convenience init(gray: Int) {
        self.init(
            r: gray,
            g: gray,
            b: gray
        )
    }
}

extension CGPoint {
    init(_ x: Int, _ y: Int) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
}

extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
}

extension CGRect {
    mutating func changeHeight(_ height: CGFloat) {
        self.size = CGSize(self.width, height)
    }
}

extension Date {
    init(year: Int, month: Int, day: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Calendar.current.locale
        formatter.timeZone = Calendar.current.timeZone
        self.init(timeInterval: 0, since: formatter.date(from: "\(year)-\(month)-\(day)")!)
    }
    
    func toString(format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Calendar.current.locale
        formatter.timeZone = Calendar.current.timeZone
        return formatter.string(from: self)
    }
}

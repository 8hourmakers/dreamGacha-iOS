//
// Created by Noverish Harold on 2017. 8. 13..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerClient {
    static let HOST = "http://8hourmakers.com/dreamgacha/api/v1.0"
    static let USER_DEFAULT_EMAIL = "email"
    static let USER_DEFAULT_PASSWORD = "password"
    static var token: String! = nil

    //callback parameter string is error message
    //if error message is nil, then this connection is success
    static func register(email: String,
                  password: String,
                  callback: @escaping (String?) -> Void) {
        let uri = "/users/"
        let json:JSON = [
                "email":email,
                "password":password
        ]

        HttpUtil.connect(url: HOST+uri, json: json, httpMethod: .post) { (res, json) in
            if !res.isSuccess() {
                callback(json["message"].stringValue)
                return
            }

            UserDefaults.standard.set(email, forKey: USER_DEFAULT_EMAIL)
            UserDefaults.standard.set(password, forKey: USER_DEFAULT_PASSWORD)
            self.token = json["token"].stringValue
            callback(nil)
        }
    }

    static func login(email: String,
                      password: String,
                      callback: @escaping (String?) -> Void) {
        let uri = "/users/auth/"
        let json:JSON = [
                "email":email,
                "password":password
        ]

        HttpUtil.connect(url: HOST+uri, json: json, httpMethod: .post) { (res, json) in
            if !res.isSuccess() {
                callback(json["message"].stringValue)
                return
            }

            UserDefaults.standard.set(email, forKey: USER_DEFAULT_EMAIL)
            UserDefaults.standard.set(password, forKey: USER_DEFAULT_PASSWORD)
            self.token = json["token"].stringValue
            callback(nil)
        }
    }
}

class HttpUtil {
    static func connect(url: String,
                        header: [String:String] = [:],
                        json: JSON,
                        httpMethod: HTTPMethod = .post,
                        callback: @escaping (HTTPURLResponse, JSON) -> Void) {
        var url = url

        if httpMethod == HTTPMethod.get {
            url += "?"
            for (key, subJson):(String, JSON) in json {
                url += "\(key)=\(subJson.rawValue)&"
            }
            //remove last '&'
            url = url.substring(to: url.index(before: url.endIndex))
        }

        let session = URLSession.shared
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        for (key, value) in header {
            request.addValue(value, forHTTPHeaderField: key)
        }

        if httpMethod != .get {
            request.httpBody = String(describing: json).data(using: String.Encoding.utf8);
        }

        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data: Data = data, let response: HTTPURLResponse = response as? HTTPURLResponse, error == nil else {
                print(url + " - " + String(describing: error))
                return
            }

            let res = String(data: data, encoding:String.Encoding.utf8)!
            print("<HTTP> \(url) : \(data) -> \(res)\n\n")

            callback(response, JSON(data))
        }
        task.resume()
    }
}

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

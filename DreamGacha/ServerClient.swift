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

        HttpUtil.send(json: json, url: HOST+uri,  httpMethod: .post) { (res, json) in
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
        
        HttpUtil.send(json: json, url: HOST+uri, httpMethod: .post) { (res, json) in
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

    static func getDreamList(lastDreamId: Int?,
                             callback: (([DreamItem]) -> Void)? = nil) {
        let uri = "/dreams/"
        var params:[String:Any] = [:]

        if let lastDreamId = lastDreamId {
            params["start_id"] = lastDreamId
        }
        
        HttpUtil.get(url: HOST+uri, params: params) { (res, json) in
            var items:[DreamItem] = []
            
            for item in json.arrayValue {
                items.append(DreamItem(item))
            }
            
            callback?(items)
        }
    }
    
    static func sendWavFile(wavFile: Data,
                            callback: ((DreamAudioItem) -> Void)? = nil) {
        
//        let array = [UInt8](wavFile)
//        
//        for byte in array {
//            print(String(format:"%2x", byte))
//        }
        
        let uri = "/dreams/audio/"
        
        HttpUtil.send(multiPart: wavFile, mimeType: "audio/x-wav", filename: "audio.wav", url: HOST+uri, httpMethod: .post) { (res, json) in
            if !res.isSuccess() {
                print(json["message"].stringValue)
                return
            }
            
            callback?(DreamAudioItem(json))
        }
    }
    
    static func makeDream(dreamAudioItem: DreamAudioItem,
                          title: String,
                          callback: ((DreamItem) -> Void)? = nil) {
        let uri = "/dreams/"
        let json:JSON = [
            "dream_audio_url": dreamAudioItem.audioUrl,
            "content": dreamAudioItem.content,
            "title": title
        ]
        
        HttpUtil.send(json: json, url: HOST+uri, httpMethod: .post) { (res, json) in
            if !res.isSuccess() {
                print(json["message"].stringValue)
                return
            }
            
            callback?(DreamItem(json))
        }
    }

    static func deleteDream(dreamId: Int,
                            callback: (() -> Void)? = nil) {
        let uri = "/dreams/\(dreamId)/"
        let json:JSON = [:]

        HttpUtil.send(json: json, url: HOST+uri, httpMethod: .delete) { (res, json) in
            if !res.isSuccess() {
                print(json["message"].stringValue)
                return
            }

            callback?()
        }
    }
}

class HttpUtil {
    static var DEFAULT_HEADER: [String:String] {
        return ["Content-Type": "application/json; charset=utf-8"]
    }
    
    static func get(url: String, header: [String:String]? = nil, params: [String:Any]? = nil, callback: ((HTTPURLResponse, JSON) -> Void)? = nil) {
        connect(url: url + createParamString(params ?? [:]),
                header: header ?? DEFAULT_HEADER,
                httpBody: nil,
                httpMethod: .get,
                callback: callback)
    }
    
    static func send(json: JSON, url: String, httpMethod: HTTPMethod = .post, header: [String:String]? = nil, callback: ((HTTPURLResponse, JSON) -> Void)? = nil) {
        connect(url: url,
                header: header ?? DEFAULT_HEADER,
                httpBody: String(describing: json).data(using: String.Encoding.utf8),
                httpMethod: httpMethod,
                callback: callback)
    }
    
    static func send(formData: [String:Any], url: String, httpMethod: HTTPMethod = .post, header: [String:String]? = nil, callback: ((HTTPURLResponse, JSON) -> Void)? = nil) {
        connect(url: url,
                header: header ?? DEFAULT_HEADER,
                httpBody: createParamString(formData).data(using: String.Encoding.utf8),
                httpMethod: httpMethod,
                callback: callback)
    }
    
    static func send(multiPart: Data, mimeType: String, filename: String, url: String, httpMethod: HTTPMethod = .post, header: [String:String]? = nil, callback: ((HTTPURLResponse, JSON) -> Void)? = nil) {
        var header = (header ?? DEFAULT_HEADER)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        header["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        let httpBody = createBody(parameters: [:], boundary: boundary, data: multiPart, mimeType: mimeType, filename: filename)
        
        connect(url: url,
                header: header,
                httpBody: httpBody,
                httpMethod: httpMethod,
                callback: callback)
    }
    
    static func connect(url: String, header: [String:String], httpBody: Data?, httpMethod: HTTPMethod, callback: ((HTTPURLResponse, JSON) -> Void)? = nil) {
        var header = header
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpBody = httpBody

        if let token = ServerClient.token {
            header["Authorization"] = "Token \(token)"
        }
        
        for (key, value) in header {
            request.addValue(value, forHTTPHeaderField: key)
        }

        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data: Data = data, let response: HTTPURLResponse = response as? HTTPURLResponse, error == nil else {
                print(url + " - " + String(describing: error))
                return
            }

            var httpBodyStr = ""
            if let httpBody = httpBody {
                httpBodyStr = String(data: httpBody, encoding:String.Encoding.utf8) ?? "\(httpBody)"
            }
            
            print("<HTTP> \(httpMethod) - \(url) : \(httpBodyStr)")

            callback?(response, JSON(data))
        }
        task.resume()
    }
    
    private static func createBody(parameters: [String: String],
                                   boundary: String,
                                   data: Data,
                                   mimeType: String,
                                   filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    private static func createParamString(_ params: [String:Any]) -> String {
        var str = ""
        
        for key in params.keys {
            str += "\(key)=\(params[key]!)&"
        }
        
        //remove last '&' if param exists
        if(str.characters.count != 0) {
            str = str.substring(to: str.index(before: str.endIndex))
        }
        
        return str
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

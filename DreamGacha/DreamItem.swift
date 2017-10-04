//
// Created by Noverish Harold on 2017. 8. 27..
// Copyright (c) 2017 8hourmakers. All rights reserved.
//

import Foundation
import SwiftyJSON

class DreamItem {
    let id: Int
    let audioUrl: String
    let title: String
    let content: String
    let createDate: String
    let updateDate : String
    
    var isSelected = false

    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.audioUrl = json["dream_audio_url"].stringValue
        self.title = json["title"].stringValue
        self.content = json["content"].stringValue
        self.createDate = json["created_timestamp"].stringValue
        self.updateDate = json["updated_timestamp"].stringValue
    }
}

class DreamAudioItem {
    let audioUrl: String
    let content: String
    
    init(_ json: JSON) {
        self.audioUrl = json["dream_audio_url"].stringValue
        self.content = json["content"].stringValue
    }
}

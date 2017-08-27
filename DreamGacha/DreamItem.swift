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

    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.audioUrl = json["dream_audio_url"].stringValue
        self.title = json["title"].stringValue
        self.content = json["content"].stringValue
        self.createDate = json["created_timestamp"].stringValue
        self.updateDate = json["updated_timestamp"].stringValue
    }

    fileprivate init(id: Int,
                    audioUrl: String,
                    title: String,
                    content: String,
                    createDate: String,
                    updateDate: String) {
        self.id = id
        self.audioUrl = audioUrl
        self.title = title
        self.content = content
        self.createDate = createDate
        self.updateDate = updateDate
    }

    static func getDummies(count: Int) -> [DreamItem] {
        var items:[DreamItem] = []

        for i in 0..<count  {
            items.append(DreamItem(id: i, audioUrl: "", title: "title\(i)", content: "content\(i)", createDate: "0000-00-00 00:00:00", updateDate: "9999-99-99 99:99:99"))
        }

        return items
    }
}

//
//  EventBus.swift
//  kuchelin
//
//  Created by Noverish Harold on 2017. 5. 30..
//  Copyright © 2017년 hyoni. All rights reserved.
//
import Foundation

class EventBus {
    static func register(_ observer: Any, event:Event, action: Selector) {
        NotificationCenter.default.addObserver(observer, selector: action, name: Notification.Name(rawValue: event.rawValue), object: nil)
    }

    static func post(event: Event, data: Any? = nil) {
        NotificationCenter.default.post(name: Notification.Name(event.rawValue), object: data)
    }

    enum Event:String {
        case deleteModeEnabled = "delete_on"
        case deleteModeDisabled = "delete_off"
        case dreamCellSelected = "dream_cell_selected"
        case dreamCellDeselected = "dream_cell_deselected"
        case dreamCellSelectAll = "dream_cell_select_all"
        case dreamCellDeselectAll = "dream_cell_deselect_all"
        case dreamCreated = "dream_created"
    }
}

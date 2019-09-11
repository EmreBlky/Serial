//
//  RecentAnalysesManager.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

class HistoryManager {
    private static let defaultsKey = "history"
    static let shared = HistoryManager()
    static let notification = Notification.Name(rawValue: "SerialHistoryManagerItemsChangedNotificationName")
    
    private init() {}
    
    func record(serialNumber: String) {
        deleteAll(serialNumber: serialNumber)
        items.append(Item(serialNumber: serialNumber, date: Date()))
    }
    
    func deleteAll(serialNumber: String) {
        items.removeAll { $0.serialNumber == serialNumber }
    }
    
    private var _items: [Item]?
    var items: [Item] {
        get {
            // Allow providing fake recents with environment variable
            if let serialNumbers = ProcessInfo.processInfo.environment["DEMO_FAKE_RECENTS"]?.split(separator: ",") {
                let date = Calendar.current.date(bySettingHour: 9, minute: 41, second: 0, of: Date()) ?? Date()
                _items = serialNumbers.map { Item(serialNumber: String($0), date: date) }
            }
            
            // Load from user defaults if not populated
            if _items == nil {
                _items = UserDefaults.standard.array(forKey: HistoryManager.defaultsKey)?.filter { $0 is Data }.compactMap { try? JSONDecoder().decode(Item.self, from: $0 as! Data) }
            }
            
            // Return (possibly newly) stored value or an empty array
            return _items ?? []
        }
        set {
            _items = Array(newValue.suffix(10))
            NotificationCenter.default.post(name: HistoryManager.notification, object: nil)
            UserDefaults.standard.set(_items!.compactMap { try? JSONEncoder().encode($0) }, forKey: HistoryManager.defaultsKey)
        }
    }
    
    struct Item: Codable {
        let serialNumber: String, date: Date
    }
}

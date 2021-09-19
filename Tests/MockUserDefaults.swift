//
//  File.swift
//
//
//  Created by Derek Clarkson on 19/9/21.
//

import UIKit
import UsefulThings

class MockUserDefaults: ObservableUserDefaults {

    var store: [String: Any] = [:]
    var observers: [String: AnyObject] = [:]

    func addObserver(_ object: NSObject, forKeyPath key: String, options _: NSKeyValueObservingOptions, context _: UnsafeMutableRawPointer?) {
        observers[key] = object
    }

    func removeObserver(_: NSObject, forKeyPath key: String) {
        observers.removeValue(forKey: key)
    }

    func set(_ newValue: Any?, forKey key: String) {

        let oldValue = store[key]

        if let new = newValue {
            store[key] = new
        } else {
            store.removeValue(forKey: key)
        }

        if let observer = observers[key] {
            var change: [NSKeyValueChangeKey: Any] = [:]
            if let old = oldValue {
                change[.oldKey] = old
            }
            if let new = newValue {
                change[.newKey] = new
            }
            observer.observeValue(forKeyPath: key, of: self, change: change, context: nil)
        }
    }

    func object(forKey key: String) -> Any? {
        return store[key]
    }

    var removeObjectForKey: String?
    func removeObject(forKey key: String) {
        store.removeValue(forKey: key)
    }
}

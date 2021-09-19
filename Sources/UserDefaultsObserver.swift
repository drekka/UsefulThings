//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/9/21.
//

import Combine
import UIKit
import XCTest

/// Protocol duplicating used funcitons from UserDeaults so that mocks can be used for testing.
public protocol ObservableUserDefaults {
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String)
    func set(_ value: Any?, forKey: String)
    func object(forKey key: String) -> Any?
    func removeObject(forKey: String)
}

extension UserDefaults: ObservableUserDefaults {}

/// Observes changes for a specific key in `UserDefaults` and calls a closure when it changes.
///
/// This observer is also capable of tracking changes across app restarts or being stopped and started multiple times. it does this by storing the latest value under a second key with the suffix "_previous" then comparing this value with the current value of the key when instantiated. If different the observer concludes that something has changed the value since it was last observed and triggers the closure. This functionality can be displayed by passing `persistState: false` as an initialiser argument.
public class UserDefaultsObserver<T>: NSObject where T: Equatable {

    private let persistedKeySuffix = "_previous"
    private let defaults: ObservableUserDefaults
    private let key: String
    private let onChange: (T?, T?) -> Void
    private let persistState: Bool

    deinit {
        defaults.removeObserver(self, forKeyPath: key)
    }

    public init(key: String,
                defaults: ObservableUserDefaults = UserDefaults.standard,
                persistState: Bool = true,
                onChange: @escaping (T?, T?) -> Void) {

        self.defaults = defaults
        self.key = key
        self.onChange = onChange
        self.persistState = persistState

        super.init()

        if persistState {
            notify(old: defaults.object(forKey: key + persistedKeySuffix), new: defaults.object(forKey: key))
        }

        defaults.addObserver(self, forKeyPath: key, options: [.old, .new], context: nil)
    }

    override public func observeValue(forKeyPath _: String?,
                                      of _: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context _: UnsafeMutableRawPointer?) {
        notify(old: change?[.oldKey], new: change?[.newKey])
    }

    private func notify(old: Any?, new: Any?) {

        let castOld: T? = cast(old)
        let castNew: T? = cast(new)

        // Only act if the value has changed.
        guard castNew != castOld else { return }
        onChange(castOld, castNew)

        // Persiste the new value as the previous value in the store.
        guard persistState else { return }
        if let castNew = castNew {
            defaults.set(castNew, forKey: key + persistedKeySuffix)
        } else {
            defaults.removeObject(forKey: key + persistedKeySuffix)
        }
    }
}

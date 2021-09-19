//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/9/21.
//

import Nimble
import UsefulThings
import XCTest

class UserDefaultsObserverTests: XCTestCase {

    private class TestClass {
        private var observer: UserDefaultsObserver<URL>!

        init() {
            observer = UserDefaultsObserver(key: "abc") { [weak self]  _, newUrl in
                if let url = newUrl {
                    self?.doSomething(with: url)
                }
            }
        }

        func doSomething(with _: URL) {}
    }

    func testObservingFirstChange() {
        runTest { $0.set("xyz", forKey: "abc") }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == true
            expect(old).to(beNil())
            expect(new as? String) == "xyz"
            expect(mock.observers.count) == 1
            expect(mock.store["abc"] as? String) == "xyz"
            expect(mock.store["abc_previous"] as? String) == "xyz"
        }
    }

    func testObservingSecondChange() {
        runTest { $0.set("123", forKey: "abc") }
        setup: {
            $0.store["abc"] = "xyz"
            $0.store["abc_previous"] = "xyz"
        }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == true
            expect(old as? String) == "xyz"
            expect(new as? String) == "123"
            expect(mock.observers.count) == 1
            expect(mock.store["abc"] as? String) == "123"
            expect(mock.store["abc_previous"] as? String) == "123"
        }
    }

    func testObservingSecondChangeToNil() {
        runTest { $0.set(nil, forKey: "abc") }
        setup: {
            $0.store["abc"] = "xyz"
            $0.store["abc_previous"] = "xyz"
        }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == true
            expect(old as? String) == "xyz"
            expect(new as? String) == nil
            expect(mock.observers.count) == 1
            expect(mock.store["abc"] as? String).to(beNil())
            expect(mock.store["abc_previous"] as? String).to(beNil())
        }
    }

    func testObservingIgnoresChangeWithSameValue() {
        runTest { $0.set("xyz", forKey: "abc") }
        setup: {
            $0.store["abc"] = "xyz"
            $0.store["abc_previous"] = "xyz"
        }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == false
            expect(old).to(beNil())
            expect(new).to(beNil())
            expect(mock.store["abc"] as? String) == "xyz"
            expect(mock.store["abc_previous"] as? String) == "xyz"
        }
    }

    func testInitTriggersClosureWhenValueSetupExternally() {
        runTest { _ in }
        setup: {
            $0.store["abc"] = "xyz"
        }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == true
            expect(old as? String) == nil
            expect(new as? String) == "xyz"
            expect(mock.store["abc"] as? String) == "xyz"
            expect(mock.store["abc_previous"] as? String) == "xyz"
        }
    }

    func testInitTriggersClosureWhenValueChangedExternally() {
        runTest { _ in }
        setup: {
            $0.store["abc_previous"] = "xyz"
            $0.store["abc"] = "123"
        }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == true
            expect(old as? String) == "xyz"
            expect(new as? String) == "123"
            expect(mock.store["abc"] as? String) == "123"
            expect(mock.store["abc_previous"] as? String) == "123"
        }
    }

    func testObservingChangeWhenPersistStateOff() {
        runTest(persistState: false) { $0.set("xyz", forKey: "abc") }
        validation: { mock, closureCalled, old, new in
            expect(closureCalled) == true
            expect(old) == nil
            expect(new as? String) == "xyz"
            expect(mock.store["abc"] as? String) == "xyz"
            expect(mock.store["abc_previous"]) == nil
        }
    }

    // MARK: - Internal

    private func runTest(
        persistState: Bool = true,
        test: (MockUserDefaults) -> Void,
        setup: ((MockUserDefaults) -> Void)? = nil,
        validation: (MockUserDefaults, Bool, Any?, Any?) -> Void
    ) {

        let mockDefaults = MockUserDefaults()
        setup?(mockDefaults)

        var oldValue: Any?
        var newValue: Any?
        var closureCalled = false
        let observer = UserDefaultsObserver<String>(key: "abc", defaults: mockDefaults, persistState: persistState) { old, new in
            oldValue = old
            newValue = new
            closureCalled = true
        }

        test(mockDefaults)

        withExtendedLifetime(observer) {
            validation(mockDefaults, closureCalled, oldValue, newValue)
        }
    }
}

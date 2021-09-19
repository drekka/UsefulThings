# UsefulThings

A library of useful bits and pieces.

# `UserDefaults` observing

`UserDefaultsObserver` is a class you can use to watch a parricular user default for changes. For example if you have a user defaults `server.url = (String) "http://abc.com`, then you could use this to monitor it for changes:

```swift
class MyClass {

    private var observer: UserDefaultsObserver<URL>!

    init() {
        observer = UserDefaultsObserver(key: "server.url") { [weak self]  _, newUrl in
            if let url = newUrl {
                self?.doSomething(with: url)
            }
        }
    }

    func doSomething(with _: URL) {
        // Do something with the new url.
    }
}
```

# `cast(...)`

`func cast<T>(_ value: Any?) -> T?` is a useful little function for casting from one type to a target type. At the moment it's main feature is the ability to cast from a `String` to a `URL` by using `URL(string:)`.  

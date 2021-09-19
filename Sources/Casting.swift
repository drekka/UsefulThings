//
//  File.swift
//  
//
//  Created by Derek Clarkson on 18/9/21.
//

import UIKit

/// Generalised cast function for casting a value of type `Any` to a mroe specific type.
///
/// This function also handles commonly applied cases such as a `String` being cast to a `URL`.
public func cast<T>(_ value: Any?) -> T? {
    switch value {
    case let cast as T:
        return cast
    case let url as String where T.self == URL.self:
        return URL(string: url) as? T
    default:
        return nil
    }
}

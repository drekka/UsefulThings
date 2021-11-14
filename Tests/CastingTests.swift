//
//  File.swift
//  
//
//  Created by Derek Clarkson on 18/9/21.
//

import XCTest
import UsefulThings
import Nimble

class CastingTests: XCTestCase {
    
    func testCasts() {
        expect(cast(5) as Int?) == 5
        expect(cast(nil) as Int?).to(beNil())
        expect(cast("abc") as Int?).to(beNil())
        expect(cast("http://abc.com") as String?) == "http://abc.com"
        expect((cast("http://abc.com") as URL?)?.absoluteString) == "http://abc.com"
        expect(cast("") as URL?).to(beNil())
        expect(cast(nil) as URL?).to(beNil())
    }
    
    func testCastFromOptional() {
        let x: Any? = 5
        if let x = cast(x) as Int? {
            expect(x) == 5
            return
        }
        fail("Cast failed")
     }
}

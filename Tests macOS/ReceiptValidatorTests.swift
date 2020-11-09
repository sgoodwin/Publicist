//
//  ReceiptValidatorTests.swift
//  PublisherTests
//
//  Created by Samuel Goodwin on 1/20/19.
//  Copyright © 2019 Roundwall Software. All rights reserved.
//

import XCTest
@testable import Publicist

class ReceiptValidatorTests: XCTestCase {

    func testValidatingMissingReceipt() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fake.receipt")
        let validator = ReceiptValidator(url: url)
        
        XCTAssertEqual(try validator.validate(), .missing)
    }
    
    func testValidatingValidReceipt() throws {
        let url = Bundle(for: ReceiptValidatorTests.self).url(forResource: "receipt", withExtension: "valid")
        let validator = ReceiptValidator(url: url!, now: Date.distantPast)
        
        XCTAssertEqual(try validator.validate(), .success)
    }

    func testValidatingExpiredReceipt() throws {
        let url = Bundle(for: ReceiptValidatorTests.self).url(forResource: "receipt", withExtension: "expired")
        let validator = ReceiptValidator(url: url!)
        
        XCTAssertEqual(try validator.validate(), .expired)
    }
    
    func testValidatingInvalidReceipt() throws {
        let url = Bundle(for: ReceiptValidatorTests.self).url(forResource: "screenshot", withExtension: "png")
        let validator = ReceiptValidator(url: url!)
        
        XCTAssertEqual(try validator.validate(), .invalid)
    }
}

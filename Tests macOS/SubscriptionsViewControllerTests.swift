//
//  SubscriptionsViewControllerTests.swift
//  PublisherTests
//
//  Created by Samuel Goodwin on 3/19/19.
//  Copyright © 2019 Roundwall Software. All rights reserved.
//

import XCTest
import StoreKit
@testable import Publicist

class SubscriptionsController: XCTestCase {
    
    class FakeProduct: SKProduct {
        override var localizedTitle: String {
            get {
                return "Poop"
            }
        }
        
        override var localizedDescription: String {
            get {
                return "Mostly just poop."
            }
        }
        
        override var price: NSDecimalNumber {
            get {
                return 0.3
            }
        }
        
        override var priceLocale: Locale {
            get {
                return Locale(identifier: "en-US")
            }
        }
    }

    func testMakingProductInfo() {
        let info = ProductInfo(FakeProduct())
        XCTAssertEqual(info.name, "Poop")
        XCTAssertEqual(info.formattedPrice, "$0.30 yearly")
    }

}

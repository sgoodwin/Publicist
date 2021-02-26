//
//  ReceiptValidator.swift
//  Publisher
//
//  Created by Samuel Goodwin on 1/13/19.
//  Copyright © 2019 Roundwall Software. All rights reserved.
//

import Foundation
import TPInAppReceipt

enum ValdationResult {
    case success
    case invalid
    case expired
    case new
    case missing
}

struct ReceiptValidator {
    let url: URL
    let now: Date
    
    init(url: URL, now: Date = Date()) {
        self.url = url
        self.now = now
    }
    
    func validate() throws -> ValdationResult {
        if !FileManager.default.fileExists(atPath: url.path) {
            return .missing
        }
        
        let data = try Data(contentsOf: url)
        let receipt = try InAppReceipt.receipt(from: data)
        try receipt.verify()
        
        if !receipt.hasPurchases {
            return .new
        }
        
        let purchases = receipt.purchases.filter({
            return $0.productIdentifier == "com.roundwallsoftware.Publisher.Yearly" || $0.productIdentifier == "com.roundwallsoftware.Publisher.UnlockFroever"
        })
        
        if purchases.count == 0 {
            return .expired
        }
        
        return .success
    }
}

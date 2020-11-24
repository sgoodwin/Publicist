//
//  ReceiptValidator.swift
//  Publisher
//
//  Created by Samuel Goodwin on 1/13/19.
//  Copyright © 2019 Roundwall Software. All rights reserved.
//

import Foundation
import AppReceiptValidator

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
        
        let validator = AppReceiptValidator()
        let parameters = AppReceiptValidator.Parameters.default.with {
            $0.receiptOrigin = .data(data)
            $0.signatureValidation = .skip
        }
        let validation = validator.validateReceipt(parameters: parameters)
        switch validation {
        case .success(let receipt, _, _):
            if receipt.inAppPurchaseReceipts.count == 0 {
                return .new
            }
            
            let purchases = receipt.inAppPurchaseReceipts.filter { (inAppPurchase) -> Bool in
                if inAppPurchase.productIdentifier == "com.roundwallsoftware.Publisher.Yearly" {
                    // We don't care anymore if the subscription is expired or not
                    return true
                }
                if inAppPurchase.productIdentifier == "com.roundwallsoftware.Publisher.UnlockFroever" {
                    return true
                }
                      
                return true
            }
            if purchases.count == 0 {
                return .expired
            }
            
            return .success
        case .error:
            return .invalid
        }
    }
}

//
//  SubscriptionController.swift
//  Tests macOS
//
//  Created by Samuel Goodwin on 11/9/20.
//

import StoreKit
import SwiftUI

struct Validity: Codable {
    let valid: Bool
    let arbitrary: String
}

class SubscriptionController: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var request: SKRequest?
    var product: SKProduct?
    
    @Published var subscriptionValid: Bool = true {
        didSet {
            if subscriptionValid {
                let manager = FileManager.default
                let url = manager.containerURL(forSecurityApplicationGroupIdentifier: "SYSB7DM9AH.Publisher")!.appendingPathComponent("validity")
                if subscriptionValid {
                    let validity = Validity(valid: true, arbitrary: "pooppooppoop")
                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .binary
                    
                    let encoded = try! encoder.encode(validity)
                    try! encoded.write(to: url)
                } else {
                    try? manager.removeItem(at: url)
                }
            }
        }
    }
    
    override init() {        
        super.init()
        
        validateSubscription()
        
        let request = SKProductsRequest(productIdentifiers: ["com.roundwallsoftware.Publisher.Yearly"])
        self.request = request
        request.delegate = self
        request.start()
        
        SKPaymentQueue.default().add(self)
    }
    
    func validateSubscription() {
        if let url = Bundle.main.appStoreReceiptURL {
            let validator = ReceiptValidator(url: url)
            let result = try! validator.validate()
            self.subscriptionValid = result == .success
            print("Subscription is valid \(self.subscriptionValid)")
        }
    }
    
    func subscribe() {
        guard let product = product else {
            return
        }
        
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }
    
    func refresh() {
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        self.request = request
        request.start()
    }
    
    func showTerms() {
        NSWorkspace.shared.open(URL(string: "https://roundwallsoftware.com/terms-of-use/")!)
    }
    
    func showPrivacy() {
        NSWorkspace.shared.open(URL(string: "https://roundwallsoftware.com/privacy-policy/")!)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.invalidProductIdentifiers.isEmpty {
            response.invalidProductIdentifiers.forEach { (invalidIdentifier) in
                print("\(invalidIdentifier) is invalid!")
            }
        } else {
            print("No invalid identifiers")
        }
        
        DispatchQueue.main.async {
            self.product = response.products[0]
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("Request finished: \(request)" )
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request failed: \(error)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                subscriptionValid = true
            }
        }
    }
}

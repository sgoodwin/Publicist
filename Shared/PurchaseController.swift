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

class PurchaseController: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var request: SKRequest?
    var product: SKProduct?
    
    @Published var subscriptionValid: Bool = true
    
    private func recordValidIfNecessary() {
        assert(Thread.isMainThread)
        let manager = FileManager.default
        let url = manager.containerURL(forSecurityApplicationGroupIdentifier: "SYSB7DM9AH.Publisher")!.appendingPathComponent("validity")
        if subscriptionValid {
            print("Recording validity receipt")
            let validity = Validity(valid: true, arbitrary: "pooppooppoop")
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            
            let encoded = try! encoder.encode(validity)
            try! encoded.write(to: url)
        } else {
            try? manager.removeItem(at: url)
        }
    }
    
    override init() {        
        super.init()
        
        validateSubscription()
        
        let request = SKProductsRequest(productIdentifiers: ["unlockforever"])
        self.request = request
        request.delegate = self
        request.start()
        
        SKPaymentQueue.default().add(self)
    }
    
    func validateSubscription() {
        if let url = Bundle.main.appStoreReceiptURL {
            print("Checking receipt at url \(url)")
            let validator = ReceiptValidator(url: url)
            let result = try! validator.validate()
            self.subscriptionValid = result == .success
            if result == .missing || result == .invalid {
                print("Receipt is missing, requesting new one")
                let request = SKReceiptRefreshRequest()
                request.delegate = self
                request.start()
            }
            
            recordValidIfNecessary()
            print("Receipt \(self) is valid after checking receipt \(self.subscriptionValid)")
        }
    }
    
    func unlock() {
        guard let product = product else {
            return
        }
        
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }
    
    func refresh() {
        SKPaymentQueue.default().restoreCompletedTransactions()
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
            return
        } else {
            print("No invalid identifiers")
        }
        
        DispatchQueue.main.async {
            self.product = response.products[0]
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("Request finished: \(request)" )
        
        DispatchQueue.main.async {
            self.validateSubscription()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKReceiptRefreshRequest {
            print("Receipt refresh failed, giving up?")
        } else {
            print("Request \(request) failed: \(error)")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Failed to restore completed receipt transactions \(error)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Receipt restore completed")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            DispatchQueue.main.async {
                if transaction.transactionState == .purchased {
                    self.subscriptionValid = true
                    self.recordValidIfNecessary()
                    print("Receipt \(self) is valid after transaction: \(self.subscriptionValid)")
                    print("Receipt thread: \(Thread.isMainThread)")
                    queue.finishTransaction(transaction)
                }
                if transaction.transactionState == .failed {
                    self.subscriptionValid = false
                    self.recordValidIfNecessary()
                    print("Receipt \(self) is valid after transaction: \(self.subscriptionValid)")
                    queue.finishTransaction(transaction)
                }
            }
        }
    }
}

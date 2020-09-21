//
//  AccountMenu.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI
import BlogEngine
import CoreData

struct AccountMenu: View {
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @FetchRequest(fetchRequest: Account.canonicalOrder()) var fetchedResults: FetchedResults
    
    @Binding var selectedAccount: Account?
    
    var body: some View {
        Menu(selectedAccount?.name ?? "Select Account") {
            ForEach(_fetchedResults.wrappedValue, id: \.self) { account in
                Button(account == selectedAccount ? "✓ " + account.name! : account.name!) {
                    selectedAccount = account
                }
            }
        }
    }
}

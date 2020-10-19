//
//  ListOfAccounts.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import CoreData
import BlogEngine

extension List {
    func ourListStyling() -> some View {
        #if os(macOS)
        return self.listStyle(SidebarListStyle())
        #else
        return self.listStyle(GroupedListStyle())
        #endif
    }
}

struct ListOfAccounts: View {
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @FetchRequest(fetchRequest: Account.canonicalOrder()) var fetchedResults: FetchedResults
    
    let progress: Progress
    @Binding var selectedAccount: Account?
    let blogEngine: BlogEngine
    
    var body: some View {
        VStack {
            List(fetchedResults, id: \.self, selection: $selectedAccount) { account in
                #if os(macOS)
                Text(verbatim: account.name!)
                #else
                NavigationLink(destination: SearchablePostsList(account: account, blogEngine: blogEngine)) {
                    Text(verbatim: account.name!)
                }
                #endif
            }
            .ourListStyling()
            
            ProgressWithStatus(progress: progress)
        }
        .navigationTitle("Accounts")
    }
}

struct ListOfAccounts_Previews: PreviewProvider {
    
    static var previews: some View {
        ListOfAccounts(progress: Progress(), selectedAccount: .constant(nil), blogEngine: BlogEngine(context: container.viewContext))
            .environment(\.managedObjectContext, container.viewContext)
    }
}

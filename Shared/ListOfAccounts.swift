//
//  ListOfAccounts.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import CoreData
import BlogEngine

struct ListOfAccounts: View {
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @FetchRequest(fetchRequest: Account.canonicalOrder()) var fetchedResults: FetchedResults
    
    let progress: Progress
    @Binding var selectedAccount: Account?
    
    var body: some View {
        VStack {
            List(fetchedResults, id: \.self, selection: $selectedAccount) { account in
                #if os(macOS)
                Text(verbatim: account.name!)
                #else
                NavigationLink(destination: SearchablePostsList(selectedAccount: .constant(account), selectedPost: nil)) {
                    Text(verbatim: account.name!)
                }
                #endif
            }
            .listStyle(SidebarListStyle())
            
            ProgressWithStatus(progress: progress)
        }
    }
}

struct ListOfAccounts_Previews: PreviewProvider {
    
    static var previews: some View {
        ListOfAccounts(progress: Progress(), selectedAccount: .constant(nil))
            .environment(\.managedObjectContext, container.viewContext)
    }
}

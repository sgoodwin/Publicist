//
//  SettingsView.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import BlogEngine
import CoreData

struct SettingsView: View {
    let blogEngine: BlogEngine
    @State var selectedAccount: Account?
    
    @State var showingSheet: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @FetchRequest(fetchRequest: Account.canonicalOrder()) var fetchedResults: FetchedResults
    
    var body: some View {
        VStack {
            List(fetchedResults, id: \.self, selection: $selectedAccount) { account in
                Text(account.name!)
            }
            
            HStack {
                Button(action: {
                    showingSheet.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
                Button(action: {
                    print("DELETE")
                }, label: {
                    Image(systemName: "minus")
                })
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
            .buttonStyle(BorderlessButtonStyle())
        }
        .sheet(isPresented: $showingSheet) {
            AddAccountForm(blogEngine: blogEngine, formObject: AccountEntryValidator(), showingSheet: $showingSheet)
                .environment(\.managedObjectContext, managedObjectContext)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(blogEngine: BlogEngine(context: container.viewContext))
    }
}

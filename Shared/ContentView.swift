//
//  ContentView.swift
//  Shared
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI
import BlogEngine
import CoreData

extension BlogEngine: ObservableObject {}

struct ContentView: View {
    @ObservedObject var blogEngine: BlogEngine
    
    @State var selectedAccount: Account?
    
    var body: some View {
        NavigationView {
            ListOfAccounts(progress: blogEngine.progress, selectedAccount: $selectedAccount, blogEngine: blogEngine)
                .frame(minWidth: 200)
            
            if let selectedAccount = selectedAccount {
                SearchablePostsList(account: selectedAccount, blogEngine: blogEngine)
            } else {
                Text("Select an account")
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: refresh, label: {
                    Image(systemName: "arrow.clockwise")
                })
            }
        }
    }
}

extension ContentView {
    func toggleSidebar() {
        #if os(macOS)
            NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar), to: nil, from: self)
        #endif
    }
    
    func refresh() {
        blogEngine.fetchPosts()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var engine: BlogEngine {
        return BlogEngine(context: container.viewContext)
    }
    
    static var previews: some View {
        ContentView(blogEngine: engine)
            .environment(\.managedObjectContext, container.viewContext)
    }
}

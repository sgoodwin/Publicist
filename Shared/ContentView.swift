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
    @State var searchText: String = ""
    
    var body: some View {
        Group {
            NavigationView {
                ListOfAccounts(progress: blogEngine.progress, selectedAccount: $selectedAccount)
                
                if let selectedAccount = selectedAccount {
                    SearchablePostsList(account: selectedAccount)
                } else {
                    Text("Select an account")
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "rectangle.lefthalf.fill")
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

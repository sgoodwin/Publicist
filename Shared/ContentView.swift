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
    @State var showingDraftSheet: Bool = false
    @State var draft: Draft?
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    
    let windowMaker = WindowMaker()
    
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
        .onOpenURL { (url) in
            if let extractor = PostExtractor(url as NSURL) {
                let tags = extractor.tags?.map({ TagObject(name: $0) }) ?? []
                let draft = Draft(title: extractor.title, markdown: extractor.contents, tags: tags, status: .draft, published_at: Date(), images: [])
                DispatchQueue.main.async {
                    #if os(macOS)
                    windowMaker.makeWindow(draft: draft, engine: blogEngine, context: managedObjectContext)
                    #else
                    print(draft.title)
                    self.draft = draft
                    showingDraftSheet = true
                    #endif
                }
            }
        }
        .sheet(isPresented: $showingDraftSheet, content: {
            if let draft = draft {
                PreviewView(draft: draft, isShowing: $showingDraftSheet, blogEngine: blogEngine)
            } else {
                Text("Missing Draft")
            }
        })
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

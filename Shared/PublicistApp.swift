//
//  PublicistApp.swift
//  Shared
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI
import BlogEngine
import WebKit

@main
struct PublicistApp: App {    
    var container: CustomPersistentContainer = {
        let container = CustomPersistentContainer.blogEngineContainer(group: nil)
        container.loadPersistentStores { (info, error) in
            if let error = error {
                fatalError(String(describing: error))
            }
        }
        return container
    }()
    
    var blogEngine: BlogEngine {
        return BlogEngine(context: container.viewContext)
    }
    
    #if os(macOS)
    let windowMaker = WindowMaker()
    #endif
    
    @State var showingDraftSheet: Bool = false
    @State var draft: Draft?
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView(blogEngine: blogEngine)
                .environment(\.managedObjectContext, container.viewContext)
            .onAppear {
                makeDemoAccountIfNeeded()
                blogEngine.fetchPosts()
            }
            .onOpenURL { (url) in
                if let extractor = PostExtractor(url as NSURL) {
                    let tags = extractor.tags?.map({ TagObject(name: $0) }) ?? []
                    let draft = Draft(title: extractor.title, markdown: extractor.contents, tags: tags, status: .draft, published_at: Date(), images: [])
                    DispatchQueue.main.async {
                        #if os(macOS)
                        windowMaker.makeWindow(draft: draft, accounts: accounts)
                        #else
                        print(draft.title)
                        self.draft = draft
                        self.showingDraftSheet = true
                        #endif
                    }
                }
            }
            .sheet(isPresented: $showingDraftSheet, content: {
                Text(draft?.title ?? "Missing Draft")
            })
        }
        .commands {
            SidebarCommands()
            ToolbarCommands()
        }
//        #if os(macOS)
//        .windowStyle(HiddenTitleBarWindowStyle())
//        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
//        #endif
        
        #if os(macOS)
        Settings {
            SettingsView(blogEngine: blogEngine)
                .environment(\.managedObjectContext, container.viewContext)
        }
        #endif
    }
    
    private func makeDemoAccountIfNeeded() {
        if try! container.viewContext.count(for: Account.canonicalOrder()) == 0 {
            Account.makeDemoAccount(context: container.viewContext)
            try! container.viewContext.save()
        }
    }
}

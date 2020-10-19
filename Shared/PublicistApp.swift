//
//  PublicistApp.swift
//  Shared
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI
import BlogEngine
import WebKit

extension Scene {
    func styleTheWindows() -> some Scene {
        #if os(macOS)
        return self.windowStyle(HiddenTitleBarWindowStyle()).windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
        #else
        return self
        #endif
    }
}

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
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView(blogEngine: blogEngine)
                .environment(\.managedObjectContext, container.viewContext)
                .onAppear {
                    makeDemoAccountIfNeeded()
                    blogEngine.fetchPosts()
                }
        }
        .commands {
            SidebarCommands()
            ToolbarCommands()
        }
        .styleTheWindows()
        
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

struct DraftView: View {
    let draft: Draft
    
    var body: some View {
        Text(draft.title)
    }
}

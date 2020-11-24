//
//  ContentView.swift
//  Shared
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI
import BlogEngine
import CoreData

extension Draft: Identifiable {
    public var id: String {
        slug
    }
}

extension BlogEngine: ObservableObject {}

struct ContentView: View {
    @ObservedObject var blogEngine: BlogEngine
    
    @State var selectedAccount: Account?
    @State var statusFilter: PostStatus?
    
    @State var draft: Draft?
    @State var error: String?
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @EnvironmentObject var subscriptionController: PurchaseController
    
    #if os(macOS)
    let windowMaker = WindowMaker()
    #endif
    
    var body: some View {
        NavigationView {
            ListOfAccounts(progress: blogEngine.progress, selectedAccount: $selectedAccount, blogEngine: blogEngine)
                .frame(minWidth: 200)
            
            VStack {
                if let selectedAccount = selectedAccount {
                    SearchablePostsList(account: selectedAccount, statusFilter: statusFilter, blogEngine: blogEngine)
                } else {
                    Spacer()
                    Text("Select an account")
                    Spacer()
                }
                SubscriptionStatusView()
            }
        }
        .onOpenURL { (url) in
            if url.scheme == "publicist" {
                return
            }
            if subscriptionController.subscriptionValid {
                extract(url)
            } else {
                error = "You do not have a valid subscription!"
            }
        }
        .handlesExternalEvents(preferring: ["*"], allowing: ["md, txt, markdown, jpg, jpeg, png"])
        .sheet(item: $draft, content: { (aDraft) -> PreviewView in
            PreviewView(draft: aDraft, blogEngine: blogEngine) {
                self.draft = nil
            }
        })
        .alert(item: $error, content: { error in
            Alert(title: Text(error))
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
            ToolbarItem(placement: .principal) {
                if selectedAccount != nil {
                    Menu(statusFilter?.rawValue.capitalized ?? "Status Filter") {
                        Button("All", action: {
                            statusFilter = nil
                        })
                        Button("Draft", action: {
                            statusFilter = .draft
                        })
                        Button("Published", action: {
                            statusFilter = .published
                        })
                        Button("Scheduled", action: {
                            statusFilter = .scheduled
                        })
                    }
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
    
    private func show(_ draft: Draft) {
        DispatchQueue.main.async {
            #if os(macOS)
            windowMaker.makeWindow(draft: draft, engine: blogEngine, context: managedObjectContext)
            #else
            self.draft = draft
            #endif
        }
    }
    
    func extract(_ url: URL) {
        if let extractor = PostExtractor(url as NSURL) {
            let tags = extractor.tags?.map({ TagObject(name: $0) }) ?? []
            let draft = Draft(title: extractor.title, markdown: extractor.contents, tags: tags, status: .draft, published_at: Date(), images: [])
            show(draft)
        }
        if let extractor = ImageExtractor(url as NSURL) {
            let draft = Draft(justImages: [ImageStruct(data: extractor.contents, url: url)])
            show(draft)
        }
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

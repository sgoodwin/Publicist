//
//  SearchablePostsList.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import BlogEngine
import UniformTypeIdentifiers

extension Post {
    static func allFrom(_ account: Account) -> FetchRequest<Post> {
        let request = Self.fetchRequest() as NSFetchRequest<Post>
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \Post.createdDate, ascending: false)]
        request.predicate = NSPredicate(format: "account = %@", account)
        return FetchRequest(fetchRequest: request)
    }
}

struct SearchablePostsList: View {
    @State var selectedPost: Post?
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    let fetchRequest: FetchRequest<Post>
    let account: Account
    let blogEngine: BlogEngine
    
    init(account: Account, blogEngine: BlogEngine) {
        self.account = account
        self.fetchRequest = Post.allFrom(account)
        self.blogEngine = blogEngine
    }
    
    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self, selection: $selectedPost) { post in
            PostCell(post: post)
                .frame(minHeight: 80)
                .onTapGesture(count: 2) {
                    openURL(account: account, post: post)
                }
                .contextMenu {
                    Button("View Article") {
                        openURL(account: account, post: post)
                    }
                    Button("Share") {
                        print("share!")
                    }
                    Button("Delete") {
                        try! blogEngine.delete(post, fromAccount: account)
                    }
                }
        }
        .onDrop(of: [UTType.fileURL], delegate: DropReceiver(selectedAccount: account, blogEngine: blogEngine))
    }
    
    func openURL(account: Account, post: Post) {
        #if os(macOS)
        NSWorkspace.shared.open(account.url(for: post)!)
        #else
        UIApplication.shared.open(account.url(for: post)!, options: [:])
        #endif
    }
}

struct DropReceiver: DropDelegate {
    let selectedAccount: Account
    let blogEngine: BlogEngine
    
    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [.fileURL])
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                
                if let extractor = PostExtractor(url as NSURL) {
                    let tags = extractor.tags?.map({ TagObject(name: $0) }) ?? []
                    let draft = Draft(title: extractor.title, markdown: extractor.contents, tags: tags, status: .draft, published_at: Date(), images: [])
                    try! blogEngine.post(draft, toAccount: selectedAccount)
                }
            }

        }
        return true
    }
}

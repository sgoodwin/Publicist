//
//  SearchablePostsList.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import BlogEngine
import UniformTypeIdentifiers

import CoreData

extension Post {
    static func allFrom(_ account: Account, status: PostStatus? = nil) -> FetchRequest<Post> {
        let request = Self.fetchRequest() as NSFetchRequest<Post>
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \Post.publishedDate, ascending: false)]
        if let status = status {
            request.predicate = NSPredicate(format: "account = %@ AND status = %@", account, status.rawValue)
        } else {
            request.predicate = NSPredicate(format: "account = %@", account)
        }
        return FetchRequest(fetchRequest: request, animation: .default)
    }
}

extension NSSharingService {
    static func submenu(url: URL) -> some View {
        return Menu(
            content: {
                buttons(url: url)
            },
            label: {
                Image(systemName: "square.and.arrow.up")
                    .accessibility(label: Text("Share"))
            }
        ).menuStyle(BorderlessButtonMenuStyle())
    }
    
    static func buttons(url: URL) -> some View {
        ForEach(NSSharingService.sharingServices(forItems: [""]), id: \.title) { item in
            Button(action: { item.perform(withItems: [url]) }) {
                Image(nsImage: item.image)
                Text(item.title)
            }
        }
    }
}

extension Post: Identifiable {
    public var id: NSManagedObjectID {
        return objectID
    }
    
    public typealias ID = NSManagedObjectID
}

struct SearchablePostsList: View {
    @Binding var selectedPost: Post?
    @State var postToDelete: Post?
    
    @Environment(\.undoManager) var undoManager
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @EnvironmentObject var subController: PurchaseController
    
    var fetchRequest: FetchRequest<Post>
    let account: Account
    let blogEngine: BlogEngine
    @Binding var error: DropError?
    
    init(account: Account, statusFilter: PostStatus?, blogEngine: BlogEngine, error: Binding<DropError?>, selectedPost: Binding<Post?>) {
        self.account = account
        self.blogEngine = blogEngine
        self.fetchRequest = Post.allFrom(account, status: statusFilter)
        _selectedPost = selectedPost
        _error = error
    }
    
    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self, selection: $selectedPost) { post in
            PostCell(post: post)
                .onDrag({ NSItemProvider(object: account.url(for: post)! as NSURL) })
                .frame(minHeight: 80)
                .contextMenu {
                    Button(action: { openURL(account: account, post: post) }) {
                        Text("View Article")
                    }
                    if post.postStatus == .draft {
                        Button(action: { try! blogEngine.publishDraftOnServer(post.objectID, toAccount: account.objectID) }) {
                            Text("Publish")
                        }
                    }
                    Button(action: {
                        postToDelete = post
                    }) {
                        Text("Delete")
                    }
                }
        }
        .onDrop(
            of: [UTType.fileURL],
            delegate: DropReceiver(
                selectedAccount: account,
                accounts: try! managedObjectContext.fetch(Account.canonicalOrder()),
                blogEngine: blogEngine,
                context: managedObjectContext,
                subController: subController, errorBlock: { error = $0 }
            )
        )
        .alert(item: $postToDelete) { (post) -> Alert in
            Alert(
                title: Text("Delete Post"),
                message: Text("Do you wish to delete \(post.title ?? "Untitled")?"),
                primaryButton: .destructive(
                    Text("Delete"),
                    action: {
                        let draft = post.draftVersion
                        let accountID = account.objectID
                        undoManager?.registerUndo(withTarget: self.blogEngine, handler: {
                            try! $0.post(draft, toAccount: accountID)
                        })
                        try! blogEngine.delete(post.objectID, fromAccount: accountID)
                        postToDelete = nil
                        selectedPost = nil
                    }
                ),
                secondaryButton: .cancel()
            )
        }
    }
    
    func openURL(account: Account, post: Post) {
        #if os(macOS)
        NSWorkspace.shared.open(account.url(for: post)!)
        #else
        UIApplication.shared.open(account.url(for: post)!, options: [:])
        #endif
    }
}

enum DropError: Error, Identifiable {
    var id: String {
        switch self {
        case .invalidSubscription:
            return "invalidSubscription"
        }
    }
    
    case invalidSubscription
}

struct DropReceiver: DropDelegate {
    let selectedAccount: Account
    let accounts: [Account]
    let blogEngine: BlogEngine
    let context: NSManagedObjectContext
    let subController: PurchaseController
    let errorBlock: (DropError) -> ()
    
    private func show(_ draft: Draft) {
        DispatchQueue.main.async {
            #if os(macOS)
            WindowMaker().makeWindow(draft: draft, engine: blogEngine, context: context)
            #else
            fatalError("I haven't implemented what to do on iOS yet!")
            #endif
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        if !subController.subscriptionValid {
            print("Making new posts is not allowed!")
            errorBlock(DropError.invalidSubscription)
            return false
        }
        
        let providers = info.itemProviders(for: [.fileURL])
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                
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
        return true
    }
}

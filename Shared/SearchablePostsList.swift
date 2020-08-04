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
    
    init(account: Account) {
        self.account = account
        self.fetchRequest = Post.allFrom(account)
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
                        print("Delete")
                    }
                }
        }
        .onDrop(of: [UTType.fileURL], delegate: DropReceiver(selectedAccount: account))
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
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
}

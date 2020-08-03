//
//  SearchablePostsList.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import BlogEngine
import UniformTypeIdentifiers

struct SearchablePostsList: View {
    @Binding var selectedAccount: Account?
    @State var selectedPost: Post?
    
    var body: some View {
        if let selectedAccount = selectedAccount {
            listWith(selectedAccount)
        } else {
            List(["Select an Account"], id: \.self) { t in
                Text(t)
            }
        }
    }
    
    func listWith(_ account: Account) -> some View {
        List(account.posts?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [Post] ?? [], id: \.self, selection: $selectedPost) { post in
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

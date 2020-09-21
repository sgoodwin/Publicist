//
//  PreviewView.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/14/20.
//

import SwiftUI
import BlogEngine

enum ParagraphItem: Hashable {
    case text(String)
    case image(Data)
}

struct PreviewView: View {
    let accounts: [String]
    let draft: Draft
    let paragraphs: [ParagraphItem]
    
    @State var selectedAccount: String?
    @State var postStatus: PostStatus = .draft
    @State var tagString: String = ""
    @State var title: String = ""
    @State var slug: String = ""
    
    init(draft: Draft, accounts: [String]) {
        self.draft = draft
        self.accounts = accounts
        self.paragraphs = draft.markdown.components(separatedBy: "\n\n").map {
            .text($0)
        }
        self.tagString = draft.tags.map({ $0.name }).joined(separator: " ")
        self.title = draft.title
        self.slug = draft.slug
        self.postStatus = draft.status
        
    }
    
    var body: some View {
        VStack {
            List(paragraphs, id: \.self) { paragraph in
                switch paragraph {
                case .text(let value):
                    Text(value)
                        .lineLimit(nil)
                        .padding(4)
                case .image(let value):
                    #if os(macOS)
                    SwiftUI.Image(nsImage: NSImage(data: value)!)
                    #else
                    SwiftUI.Image(uiImage: UIImage(data: value)!)
                    #endif
                }
            }
            
            VStack {
                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                    TextField("Slug", text: $slug)
                        .frame(maxWidth: 120)
                }
                HStack {
                    Text("Tags")
                    TextField("Tags", text: $tagString)
                }
            }
            .padding([.leading, .trailing, .top], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            HStack {
                Button("Cancel") {
                    print("Cancel!")
                }
                
                Spacer(minLength: 50)
                
                Menu(selectedAccount ?? "Select Account") {
                    ForEach(accounts, id: \.self) { account in
                        Button(account == selectedAccount ? "✓ " + account : account) {
                            selectedAccount = account
                        }
                    }
                }
                
                Spacer(minLength: 50)
                
                Menu(postStatus.rawValue.capitalized) {
                    Button((postStatus == .draft ? " ✓" : "") + "Draft") {
                        postStatus = .draft
                    }
                    Button((postStatus == .published ? " ✓" : "") + "Published") {
                        postStatus = .published
                    }
                }
                
                Button("Post") {
                    print("Do it!")
                }
            }
            .padding([.leading, .trailing, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(
            draft: Draft(
                title: "This is a blog post!",
                markdown: "This is a post I wrote.\n\nThis is another paragraph. You can type whatever you want, and it'll display it."
            ), accounts: ["roundwallsoftware.com", "nihongowobenkyou.wordpress.com"]).frame(maxWidth: 1000)
    }
}

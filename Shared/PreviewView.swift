//
//  PreviewView.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/14/20.
//

import SwiftUI
import BlogEngine
import CoreData

enum ParagraphItem: Hashable {
    case text(String)
    case image(String, ImageStruct)
}

struct PreviewView: View {
    @State var paragraphs: [ParagraphItem] = []
    @State var draft: Draft
    @State var selectedAccount: Account?
    
    let blogEngine: BlogEngine
    
    let close: () -> Void
    
    var body: some View {
        VStack {
            #if os(iOS)
            HStack {
                Button("Cancel", action: close)
                
                Spacer()
                
                Button("Post", action: post)
                .disabled(selectedAccount == nil)
            }
            .padding(8)
            #endif
            
            ParagraphsView(paragraphs: $paragraphs)
            
            FormFields(draft: $draft)
            
            DraftButtons(selectedAccount: $selectedAccount, draft: $draft, cancel: close, post: post)
            .padding([.leading, .trailing, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            paragraphs = draft.markdown.components(separatedBy: "\n\n").map { line in
                if line.hasPrefix("![](") {
                    if let image = draft.images.first(where: { image in
                        return line.contains(image.url.absoluteString)
                    }) {
                        return .image(line, image)
                    }
                }
                return .text(line)
            }
        }
    }
    
    func post() {
        if let account = selectedAccount {
            try! blogEngine.post(draft, toAccount: account)
            close()
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var engine: BlogEngine {
        return BlogEngine(context: container.viewContext)
    }
    
    static var previews: some View {
        PreviewView(
            draft: Draft(
                title: "This is a blog post!",
                markdown: "This is a post I wrote.\n\nThis is another paragraph. You can type whatever you want, and it'll display it."
            ),
            blogEngine: engine,
            close: { print("close!") }
        )
        .frame(maxWidth: 1000)
        .environment(\.managedObjectContext, container.viewContext)
    }
}

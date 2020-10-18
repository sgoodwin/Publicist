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
    case image(Data)
}

struct PreviewView: View {
    @State var paragraphs: [ParagraphItem] = []
    @State var draft: Draft
    @State var selectedAccount: Account?
    
    @Binding var isShowing: Bool
    
    let blogEngine: BlogEngine
    
    var body: some View {
        VStack {
            #if os(iOS)
            HStack {
                Button("Cancel", action: cancel)
                
                Spacer()
                
                Button("Post", action: post)
                .disabled(selectedAccount == nil)
            }
            .padding(8)
            #endif
            
            ParagraphsView(paragraphs: $paragraphs)
            
            FormFields(draft: $draft)
            
            DraftButtons(selectedAccount: $selectedAccount, draft: $draft, cancel: cancel, post: post)
            .padding([.leading, .trailing, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            paragraphs = draft.markdown.components(separatedBy: "\n\n").map {
                .text($0)
            }
        }
    }
    
    func cancel() {
        isShowing = false
    }
    
    func post() {
        if let account = selectedAccount {
            try! blogEngine.post(draft, toAccount: account)
            isShowing = false
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
            isShowing: .constant(false),
            blogEngine: engine
        )
        .frame(maxWidth: 1000)
        .environment(\.managedObjectContext, container.viewContext)
    }
}

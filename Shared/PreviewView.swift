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
    
    var body: some View {
        VStack {
            ParagraphsView(paragraphs: $paragraphs)
            
            FormFields(draft: $draft)
            
            HStack {
                Button("Cancel") {
                    print("Cancel!")
                }
                
                Spacer(minLength: 50)
                
                AccountMenu(selectedAccount: $selectedAccount)
                
                Spacer(minLength: 50)
                
                StatusMenu(draft: $draft)
                
                Spacer()
                
                Button("Post") {
                    print("Do it! \(draft.title), \(draft.status)")
                }
            }
            .padding([.leading, .trailing, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            paragraphs = draft.markdown.components(separatedBy: "\n\n").map {
                .text($0)
            }
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
            )
        )
        .frame(maxWidth: 1000)
        .environment(\.managedObjectContext, container.viewContext)
    }
}

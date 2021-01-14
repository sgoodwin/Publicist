//
//  FormFields.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI
import BlogEngine

struct FormFields: View {
    @Binding var draft: Draft
    
    @State var tags: String = "Figure out tags here"
    
    var body: some View {
        VStack {
            #if os(macOS)
            HStack {
                Text("Title:")
                TextField("Title", text: $draft.title)
                TextField("Slug", text: $draft.slug)
                    .frame(maxWidth: 120)
            }
            HStack {
                Text("Tags:")
                TagsField(tags: $draft.tags)
                DatePicker("Published Date", selection: $draft.published_at, displayedComponents: [.date])
                    .onChange(of: draft.published_at) { (date) in
                        if date > Date() {
                            draft.status = .scheduled
                        } else {
                            draft.status = .published
                        }
                    }
            }
            #else
            HStack {
                Text("Title:")
                TextField("Title", text: $draft.title)
            }
            HStack {
                Text("Slug:")
                TextField("Slug", text: $draft.slug)
            }
            HStack {
                Text("Tags:")
                TextField("Tags", text: $tags)
            }
            #endif
        }
        .padding([.leading, .trailing, .top], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

struct FormFields_Previews: PreviewProvider {
    static var previews: some View {
        FormFields(
            draft: .constant(
                Draft(
                    title: "This is a longer title.",
                    markdown: "this is markdown"
                )
            )
        )
    }
}

struct TagsField: View {
    @Binding var tags: [TagObject]
    
    var body: some View {
        TextField("Tags", text: Binding(get: {
            tags.map({ $0.name }).joined(separator: ", ")
        }, set: { newValue in
            tags = newValue.components(separatedBy: ", ").map({ TagObject(name: $0) })
        }))
    }
}

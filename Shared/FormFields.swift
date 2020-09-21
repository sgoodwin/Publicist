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
            HStack {
                Text("Title")
                TextField("Title", text: $draft.title)
                TextField("Slug", text: $draft.slug)
                    .frame(maxWidth: 120)
            }
            HStack {
                Text("Tags")
                TextField("Tags", text: $tags)
            }
        }
        .padding([.leading, .trailing, .top], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

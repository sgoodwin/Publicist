//
//  Paragraphs.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI

struct ParagraphsView: View {
    @Binding var paragraphs: [ParagraphItem]
    
    var body: some View {
        List {
            ForEach(paragraphs, id: \.self) { paragraph in
                switch paragraph {
                case .text(let value):
                    Text(value)
                        .lineLimit(nil)
                        .padding(4)
                case .image(let value):
                    SwiftUI.Image(nsImage: NSImage(data: value)!)
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
            }
            .onInsert(of: [.image], perform: insert)
        }
        .listStyle(PlainListStyle())
    }
    
    func insert(index: Int, providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: "public.image") { (data, error) in
                if let data = data {
                    paragraphs.insert(.image(data), at: index)
                }
            }
        }
    }
}

struct ParagraphsDropDelegate: DropDelegate {
    let gotImage: (Data) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [.image])
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: "public.image") { (data, error) in
                if let data = data {
                    gotImage(data)
                }
            }
        }
        return true
    }
}

struct ParagraphsView_Previews: PreviewProvider {
    static let paragraphs: [ParagraphItem] = [
        .text("This is the first paragraph."),
        .text("This is the second paragraph, it's very important that you pay attention and do the right stuff."),
        .text("People will notice if you half-ass it you big dummy-face, do it right.")
    ]
    
    static var previews: some View {
        ParagraphsView(paragraphs: .constant(paragraphs))
    }
}

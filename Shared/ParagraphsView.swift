//
//  Paragraphs.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI
import BlogEngine

struct ParagraphsView: View {
    struct MyDropDelegate: DropDelegate {
        func performDrop(info: DropInfo) -> Bool {
            print(info)
            return true
        }
    }
    
    @Binding var paragraphs: [ParagraphItem]
    @State var selectedParagraph: ParagraphItem?
    
    var body: some View {
        List(selection: $selectedParagraph) {
            ForEach(paragraphs, id: \.self) { paragraph in
                switch paragraph {
                case .text(let value):
                    Text(verbatim: value)
                        .lineLimit(nil)
                        .padding(4)
                case .image(let line, let imageStruct):
                    VStack(alignment: .center) {
                        Text(verbatim: line)
                        SwiftUI.Image.from(data: imageStruct.data)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                    }
                }
            }
            .onInsert(of: [.image, .jpeg, .png], perform: insert)
            .onDrop(of: [.image, .jpeg, .png], delegate: MyDropDelegate())
        }
        .listStyle(PlainListStyle())
    }
    
    func insert(index: Int, providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadFileRepresentation(forTypeIdentifier: "public.image") { (fileURL, error) in
                if let fileURL = fileURL, let data = try? Data(contentsOf: fileURL) {
                    let item = ParagraphItem.image("![](\(fileURL)", ImageStruct(data: data, url: fileURL))
                    paragraphs.insert(item, at: index)
                }
            }
        }
    }
}

struct ParagraphsView_Previews: PreviewProvider {
    static var paragraphs: [ParagraphItem] = [
        .text("This is the first paragraph."),
        .text("This is the second paragraph, it's very important that you pay attention and do the right stuff."),
        .text("People will notice if you half-ass it you big dummy-face, do it right.")
    ]
    
    static var previews: some View {
        ParagraphsView(paragraphs: Binding(get: { paragraphs }, set: { paragraphs = $0 }))
    }
}

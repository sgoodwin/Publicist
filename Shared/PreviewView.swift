//
//  PreviewView.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/14/20.
//

import SwiftUI
import BlogEngine
import CoreData

class ParagraphItem: Hashable, Identifiable, ObservableObject {
    static func == (lhs: ParagraphItem, rhs: ParagraphItem) -> Bool {
        return lhs.line == rhs.line && lhs.image == rhs.image
    }
    
    var id: String {
        return line
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(line)
        hasher.combine(image)
        hasher.combine(caption)
    }
    
    @Published var line: String
    @Published var image: ImageStruct?
    @Published var caption: String? {
        didSet {
            if let caption = caption {
                line = "![\(caption)](\(image!.url)"
            }
        }
    }
    
    init(_ line: String) {
        print(line)
        self.line = line
    }
    
    init(_ line: String, image: ImageStruct) {
        self.image = image
        
        if let generated = line.filter({ !"![]".contains($0) }).split(separator: "(").first {
            self.caption = String(generated)
            self.line = line
        } else {
            self.caption = nil
            self.line = "![](\(image.url))"
        }
    }
}

struct PreviewView: View {
    @State var draft: Draft
    let blogEngine: BlogEngine
    let close: () -> Void
    
    @State var paragraphs: [ParagraphItem]
    @State var selectedAccount: Account?
    
    init(draft: Draft, blogEngine: BlogEngine, close: @escaping () -> Void) {
        _draft = State(initialValue: draft)
        self.blogEngine = blogEngine
        self.close = close
        
        let lines: [ParagraphItem] = draft.markdown.components(separatedBy: "\n\n").map { line in
            if line.hasPrefix("![") {
                if let image = draft.images.first(where: { image in
                    return line.contains(image.url.absoluteString)
                }) {
                    return ParagraphItem(line, image: image)
                }
            }
            return ParagraphItem(line)
        }
        _paragraphs = State(initialValue: lines)
    }
    
    var body: some View {
        VStack {
            List() {
                ForEach(paragraphs, id: \.id) { paragraph in
                    ParagraphView(paragraph: paragraph)
                }
                .onInsert(of: [.fileURL], perform: insert)
            }
            .listStyle(PlainListStyle())
            
            FormFields(draft: $draft)

            DraftButtons(selectedAccount: $selectedAccount, draft: $draft, cancel: close, post: post)
            .padding([.leading, .trailing, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
    }
    
    func insert(index: Int, providers: [NSItemProvider]) {
        print("inserting!")
        for provider in providers {
            print(provider.registeredTypeIdentifiers)
            
            if provider.hasItemConformingToTypeIdentifier("public.image") {
                provider.loadFileRepresentation(forTypeIdentifier: "public.image") { (fileURL, error) in
                    if let fileURL = fileURL, let data = try? Data(contentsOf: fileURL) {
                        let item = ParagraphItem("![\(fileURL.deletingPathExtension().lastPathComponent)](\(fileURL)", image: ImageStruct(data: data, url: fileURL))
                        print("Inserted! \(item.line)")
                        paragraphs.insert(item, at: index)
                    }
                }
            } else {
                _ = provider.loadObject(ofClass: URL.self) { (fileURL, error) in
                    guard let fileURL = fileURL else {
                        print("Missing file url!")
                        return
                    }
                    
                    guard let data = try? Data(contentsOf: fileURL) else {
                        print("Missing data!")
                        return
                    }
                    
                    if NSImage(data: data) != nil {
                        let item = ParagraphItem("![\(fileURL.deletingPathExtension().lastPathComponent)](\(fileURL))", image: ImageStruct(data: data, url: fileURL))
                        print("Inserted! \(item.line)")
                        paragraphs.insert(item, at: index)
                    }
                }
            }
        }
    }
    
    func post() {
        if let account = selectedAccount {
            draft.markdown = paragraphs.map({ $0.line }).joined(separator: "\n")
            draft.images = paragraphs.compactMap({ $0.image })
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

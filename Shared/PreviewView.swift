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

extension Draft {
    init(items: [ParagraphItem]) {
        self.init(title: "you did it", markdown: "whoop")
    }
}

struct PreviewView: View {
    let draft: Draft
    @State var paragraphs: [ParagraphItem] = []
    
    @State var selectedAccount: Account?
    @State var selectedParagraph: ParagraphItem?
    
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
            
            List(selection: $selectedParagraph) {
                ForEach(paragraphs, id: \.self) { paragraph in
                    ParagraphView(paragraph: paragraph)
                }
                .onInsert(of: [.image, .jpeg, .png, .fileURL], perform: insert)
            }
            .listStyle(PlainListStyle())
            
//            FormFields(draft: $draft)
//
//            DraftButtons(selectedAccount: $selectedAccount, draft: $draft, cancel: close, post: post)
//            .padding([.leading, .trailing, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            paragraphs = draft.markdown.components(separatedBy: "\n\n").map { line in
                if line.hasPrefix("![") {
                    if let image = draft.images.first(where: { image in
                        return line.contains(image.url.absoluteString)
                    }) {
                        return ParagraphItem(line, image: image)
                    }
                }
                return ParagraphItem(line)
            }
        }
    }
    
    func insert(index: Int, providers: [NSItemProvider]) {
        print("inserting!")
        for provider in providers {
            print(provider.registeredTypeIdentifiers)
            
            if provider.hasItemConformingToTypeIdentifier("public.image") {
                provider.loadFileRepresentation(forTypeIdentifier: "public.image") { (fileURL, error) in
                    print(fileURL ?? "no file url!")
                    if let fileURL = fileURL, let data = try? Data(contentsOf: fileURL) {
                        let item = ParagraphItem("![\(fileURL.deletingPathExtension().lastPathComponent)](\(fileURL)", image: ImageStruct(data: data, url: fileURL))
                        paragraphs.insert(item, at: index)
                    }
                }
            } else {
                provider.loadFileRepresentation(forTypeIdentifier: "public.file-url") { (fileURL, error) in
                    print(fileURL ?? "no file url!")
                    let values = try? fileURL?.resourceValues(forKeys: [.typeIdentifierKey])
                    
                    if let fileURL = fileURL, values?.typeIdentifier == "public.image", let data = try? Data(contentsOf: fileURL) {
                        let item = ParagraphItem("![\(fileURL.deletingPathExtension().lastPathComponent)](\(fileURL)", image: ImageStruct(data: data, url: fileURL))
                        paragraphs.insert(item, at: index)
                    }
                }
            }
        }
    }
    
    func post() {
        if let account = selectedAccount {
            try! blogEngine.post(Draft(items: paragraphs), toAccount: account)
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

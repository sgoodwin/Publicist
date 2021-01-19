//
//  ParagraphView.swift
//  iOS
//
//  Created by Samuel Goodwin on 1/13/21.
//

import Foundation
import SwiftUI

struct ParagraphView: View {
    let paragraph: ParagraphItem
    @State var caption: String = ""
    
    var body: some View {
        if let image = paragraph.image {
            VStack(alignment: .center, spacing: 4) {
                Image(nsImage: NSImage(data: image.data)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                TextField("caption", text: $caption, onCommit:  {
                    paragraph.caption = caption
                }).onAppear {
                    caption = paragraph.caption ?? ""
                }
                .multilineTextAlignment(.center)
            }
        } else {
            Text(paragraph.line)
                .multilineTextAlignment(.leading)
        }
    }
}

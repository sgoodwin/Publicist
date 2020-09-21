//
//  Paragraphs.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI

struct ParagraphsView: View {
    let paragraphs: [ParagraphItem]
    
    var body: some View {
        List(paragraphs, id: \.self) { paragraph in
            switch paragraph {
            case .text(let value):
                Text(value)
                    .lineLimit(nil)
                    .padding(4)
            case .image(let value):
                SwiftUI.Image(uiImage: UIImage(data: value)!)
            }
        }
    }
}

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
    
    var body: some View {
        VStack(spacing: 8) {
            if let image = paragraph.image {
                Image(nsImage: NSImage(data: image.data)!)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .frame(width: 300, height: 300)
                if let caption = paragraph.caption {
                    Text(caption)
                        .multilineTextAlignment(.leading)
                }
            } else {
                Text(paragraph.line)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

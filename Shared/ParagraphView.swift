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
        VStack {
            if let image = paragraph.image {
                Image(nsImage: NSImage(data: image.data)!)
            }
            Text(paragraph.line)
        }
    }
}

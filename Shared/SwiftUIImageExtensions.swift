//
//  SwiftUIImageExtensions.swift
//  Publicist
//
//  Created by Samuel Goodwin on 10/19/20.
//

import SwiftUI

extension Image {
    static func from(data: Data) -> Image {
        #if os(macOS)
        return Image(nsImage: NSImage(data: data)!)
        #else
        return Image(uiImage: UIImage(data: data)!)
        #endif
    }
}

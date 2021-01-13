//
//  SwiftUIImageExtensions.swift
//  Publicist
//
//  Created by Samuel Goodwin on 10/19/20.
//

import SwiftUI

extension Image {
    static func from(data: Data) -> Image? {
        #if os(macOS)
        print("Trying to make image from data")
        guard let image = NSImage(data: data) else {
            print("Couldn't make an image from data")
            return nil
        }
        return Image(nsImage: image)
        #else
        guard let image = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: image)
        #endif
    }
}

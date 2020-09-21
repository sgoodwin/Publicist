//
//  View+Sharing.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI

extension View {
    func share(_ items: [Any]) {
        #if os(macOS)
        print("Share!")
        #else
        let share = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(share, animated: true, completion: nil)
        #endif
    }
}

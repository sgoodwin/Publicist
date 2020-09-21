//
//  StatusMenu.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI
import BlogEngine

struct StatusMenu: View {
    @Binding var draft: Draft
    
    var body: some View {
        Menu(draft.status.rawValue.capitalized) {
            Button((draft.status == .draft ? " ✓" : "") + "Draft") {
                draft.status = .draft
            }
            Button((draft.status == .published ? " ✓" : "") + "Published") {
                draft.status = .published
            }
        }
    }
}

//
//  DraftButtons.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/28/20.
//

import SwiftUI
import BlogEngine

struct DraftButtons: View {
    @Binding var selectedAccount: Account?
    @Binding var draft: Draft
    
    let cancel: () -> ()
    let post: () -> ()
    
    var body: some View {
        #if os(macOS)
        HStack {
            Button("Cancel", action: cancel)
            
            Spacer(minLength: 50)
            
            AccountMenu(selectedAccount: $selectedAccount)
            
            Spacer(minLength: 50)
            
            StatusMenu(draft: $draft)
            
            Spacer()
            
            Button("Post", action: post)
        }
        #else
        HStack {
            AccountMenu(selectedAccount: $selectedAccount)
            
            Spacer()
            
            StatusMenu(draft: $draft)
        }
        #endif
    }
}

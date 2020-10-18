//
//  WindowMaker.swift
//  macOS
//
//  Created by Samuel Goodwin on 9/21/20.
//

import Cocoa
import BlogEngine
import SwiftUI
import CoreData

class WindowMaker {
    var draftWindow: NSWindow?
    
    func makeWindow(draft: Draft, engine: BlogEngine, context: NSManagedObjectContext) {
        let window = NSWindow(
            contentViewController: NSHostingController(rootView:
                PreviewView(draft: draft, isShowing: .constant(true), blogEngine: engine).frame(minWidth: 500, minHeight: 500)
                                                        .environment(\.managedObjectContext, context)
            )
        )
        window.title = "New Post"
        window.isOpaque = true
        window.minSize = NSSize(width: 500, height: 500)
        window.isMovableByWindowBackground = true
        window.toolbarStyle = .unified
        window.styleMask = [.fullSizeContentView, .closable, .titled, .miniaturizable, .resizable, .unifiedTitleAndToolbar]

        window.center()

        let controller = NSWindowController(window: window)
        controller.showWindow(nil)

        draftWindow = window
    }
}

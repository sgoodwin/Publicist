//
//  PreviewCoreDataStack.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import BlogEngine
import CoreData

extension PreviewProvider {
    static var container: CustomPersistentContainer {
        let container = CustomPersistentContainer.blogEngineContainer(group: nil)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        
        container.persistentStoreDescriptions = [
            description
        ]
        container.loadPersistentStores { (d, error) in
            fatalError(error?.localizedDescription ?? "Don't know why it failed")
        }
        return container
    }
}

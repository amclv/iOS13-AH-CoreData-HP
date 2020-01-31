//
//  CoreDataStack.swift
//  HarryPotter-CoreData-xcode
//
//  Created by Austin Potts on 1/29/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData




class CoreDataStack {
    
    static let share = CoreDataStack()
    
    private init() {
        
    }
    
    //Create Code Snippet
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Spells")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Error loading Persistent Stores: \(error)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }() // Creating only one instance for use
    
    
    
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.share.mainContext) {
        
        context.performAndWait {
            do{
                try context.save()
            } catch {
                NSLog("Error saving context \(error)")
            }
        }
    }
    
    
}

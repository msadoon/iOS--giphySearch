//
//  CoreDataStack.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-07.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation
import CoreData

open class GSCoreDataStack {
    
    public var modelName: String
    
    public static let sharedInstance = GSCoreDataStack(name: "giphySearch")
    
    public init(name: String) {
        self.modelName = name
    }
    
    public lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    public lazy var newBackgroundContext: NSManagedObjectContext = {
        return self.storeContainer.newBackgroundContext()
    }()
    
    public lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    public func saveMainContext() {
        
        mainContext.perform{
            do {
                try self.mainContext.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func saveContext(context:NSManagedObjectContext) {
        
        if (context != mainContext) {
            context.perform {
                do {
                    try context.save()
                    self.saveMainContext()
                } catch let error as NSError {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        } else {
            saveMainContext()
        }
        
    }
    
}

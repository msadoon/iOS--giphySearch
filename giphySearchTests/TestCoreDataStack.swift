//
//  TestCoreDataStack.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-06.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation
import CoreData
import giphySearch

public class TestCoreDataStack: GSCoreDataStack {
    
    convenience init() {
        self.init(name: "giphySearch")
    }
    
    override init(name: String) {
        super.init(name: name)
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        self.storeContainer = container
    }
}

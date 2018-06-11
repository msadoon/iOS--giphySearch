//
//  TestDataManager.swift
//  giphySearchTests
//
//  Created by Mubarak Sadoon on 2018-06-10.
//  Copyright © 2018 msadoon. All rights reserved.
//

import XCTest
import CoreData
import FLAnimatedImage
@testable import giphySearch

class DataManagerTests: XCTestCase {
    
    var stack:TestCoreDataStack!
    var dataManager:GSDataManager!
    var managedContext:NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        stack = TestCoreDataStack()
        managedContext = stack.mainContext
        dataManager = GSDataManager(stack: stack, context: managedContext)
        
        let testEntityForFindingAndDeleting = NSEntityDescription.entity(
            forEntityName: "GSGif",
            in: managedContext)!
        let newTestGif = GSGif(entity: testEntityForFindingAndDeleting,
                               insertInto: managedContext)
        newTestGif.name = "on my way goodbye GIF by Bubble Punk"
        newTestGif.id = "cfuL5gqFDreXxkWQ4o"
        newTestGif.url = URL(string:"https://media3.giphy.com/media/cfuL5gqFDreXxkWQ4o/giphy-downsized.gif")
        newTestGif.height = 200
        newTestGif.width = 200
        newTestGif.searchTerm = "Cats"
        if self.managedContext.hasChanges {
            self.stack.saveContext(context: managedContext)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        stack = nil
        managedContext = nil
        dataManager = nil
    }
    
    //update entity rank
    //find all GIFS
    
    //Mark: Testing Network Related Methods
    func testGettingImagesForURLS() {
        let sampleSetOfIndexPathsWithURLS = [0: URL(string: "https://media3.giphy.com/media/cfuL5gqFDreXxkWQ4o/giphy-downsized.gif"),
                                             1: URL(string: "https://media1.giphy.com/media/Ov5NiLVXT8JEc/giphy.gif")]
        
        dataManager.getImagesForURLS(allImageData: sampleSetOfIndexPathsWithURLS as! [Int : URL])
        
        expectation(forNotification: .convertedURLToImages,
                    object: nil) {
                        (notification) -> Bool in
                        
                        if let foundDict:[Int:FLAnimatedImage] = notification.object as? [Int:FLAnimatedImage] {
                            if foundDict.keys.count > 1 {
                                if let _:FLAnimatedImage = foundDict[0],
                                    let _:FLAnimatedImage = foundDict[1] {
                                    return true
                                } else {
                                    return false
                                }
                            } else {
                                return false
                            }
                            
                            
                        } else {
                            return false
                        }
        }
        
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Data didn't come back or came back incorrectly")
        }
        
    }
    //MARK: Create
    func testAddingNewGSGifEntitiesToStack() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: managedContext) {
                        notification in return true
        }
        
        managedContext.perform {
            let result = self.dataManager.getAllGiphJSONData(searchTerm:"Cats", newSearch: true)
            XCTAssertTrue(result, "Network starting download data.")
        }
        
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
        
    }
    
    //MARK: Update
    func testUpdatingNewGSGifEntitiesToStack() {
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: managedContext) {
                        notification in return true
        }
        
        managedContext.perform {
            if let testGif = self.dataManager.findAGif(id: "cfuL5gqFDreXxkWQ4o") {
                self.dataManager.updateGifRank(gif:testGif, newRank: 6)
            } else {
                XCTAssert(false, "Could not find Gif to Update")
            }
        }
        
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    //MARK: Delete
    func testFindingAndDeletingExistingGSGifsFromStack() {
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: stack.mainContext) {
                        notification in return true
        }
        
        managedContext.perform {
            self.dataManager.deleteAllGifs(searchTerm: "Cats")
        }
        
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Delete did not occur")
        }
    }
}

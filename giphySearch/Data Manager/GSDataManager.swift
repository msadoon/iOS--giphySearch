//
//  GSDataManager.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-07.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation
import CoreData
import FLAnimatedImage

class GSDataManager {
    
    let coreDataStack:GSCoreDataStack
    let managedContext:NSManagedObjectContext
    
    static let sharedInstance:GSDataManager = GSDataManager()
    
    private var gifs:[[String:AnyObject]] = []
    private var gifsForVisibleCells:[Int:AnyObject] = [:]
    private var gettingACurrentBatchOfGifs:Bool = false
    private var currentNumberOfGifsDownloadedForSearchTerm:Int = 0
    private let queue:OperationQueue = OperationQueue()
    
    var getCurrentLimit:Int = {
        return GSNetworkManager.currentLimit
    }()
    
    public init() {
        self.coreDataStack = GSCoreDataStack.sharedInstance
        self.managedContext = coreDataStack.newBackgroundContext
        queue.maxConcurrentOperationCount = 4
        
    }
    
    //MARK: Core Data Operations
    
    func addNewGifs() {
        
        var newGifObjects:[String:FLAnimatedImage] = [:]
        
        for index in 0..<gifs.count {
            
            if let foundGifName:String = gifs[index]["name"] as? String,
                let foundGifIDString:String = gifs[index]["id"] as? String,
                let foundGifAnimatedImage:FLAnimatedImage = gifs[index]["animatedImage"] as? FLAnimatedImage,
                let foundGifURL:URL = gifs[index]["url"] as? URL,
                let foundGifHeight:String = gifs[index]["height"] as? String,
                let foundGifWidth:String = gifs[index]["width"] as? String,
                let foundGifHeightInt:Int = Int(foundGifHeight),
                let foundGifWidthInt:Int = Int(foundGifWidth){
                let entity = NSEntityDescription.entity(
                    forEntityName: "GSGif",
                    in: managedContext)!
                let newGif = GSGif(entity: entity,
                                    insertInto: managedContext)
                
                newGif.name = foundGifName
                newGif.id = foundGifIDString
                newGif.url = foundGifURL
                newGif.height = Int32(foundGifHeightInt)
                newGif.width = Int32(foundGifWidthInt)
                newGif.searchTerm = GSNetworkManager.currentSearchTerm
                
                newGifObjects[foundGifIDString] = foundGifAnimatedImage
                
            }
            
        }
        
        currentNumberOfGifsDownloadedForSearchTerm += gifs.count
        
        gifs = []
        
        if self.managedContext.hasChanges {
            self.coreDataStack.saveContext(context: managedContext)
        }
        
        self.gettingACurrentBatchOfGifs = false
        
        NotificationCenter.default.post(name: .newGifsDownloaded, object: newGifObjects)
        
    }
    
    func updateGifRank(gif:GSGif, newRank: Int) {

        gif.rank = Int32(newRank)
        
        if self.managedContext.hasChanges {
            self.coreDataStack.saveContext(context: managedContext)
        }

        NotificationCenter.default.post(name: .gifUpdatedRank, object: nil)

    }

    func deleteAllGifs(searchTerm: String) {
        
        let allGifsForSearchTerm = findAllGifs(searchTerm: searchTerm)
        
        for gif in allGifsForSearchTerm {
            self.managedContext.delete(gif)
        }
        
        if self.managedContext.hasChanges {
            self.coreDataStack.saveContext(context: managedContext)
        }
        
        NotificationCenter.default.post(name: .deletedAllGifsForSearchTerm, object: nil)
    }
    
    func findAllGifs(searchTerm: String) -> [GSGif] {
        let gsgifFetchRequest:NSFetchRequest<GSGif> = GSGif.fetchRequest()
        gsgifFetchRequest.predicate = NSPredicate(format: "searchTerm == %@", searchTerm)
        
        var allResults:[GSGif] = []
        
        do {
            allResults = try self.managedContext.fetch(gsgifFetchRequest)
            if allResults.count > 0 {
                return allResults
            }
        } catch {
            return allResults
        }
        
        return allResults
    }
    
    func addNewGifsForVisibleCells() {
        
        var newGifObjects:[Int:FLAnimatedImage] = [:]
        
        for key in gifsForVisibleCells.keys {
            if let foundGifAnimatedImage:FLAnimatedImage = gifsForVisibleCells[key] as? FLAnimatedImage {
                newGifObjects[key] = foundGifAnimatedImage
            }
        }
        
        gifsForVisibleCells = [:]
        
        NotificationCenter.default.post(name: .convertedAllImages, object: newGifObjects)
        
    }
    
    //MARK: Network

    func getAllGiphJSONData(searchTerm:String) -> Bool {
        
        if !self.gettingACurrentBatchOfGifs {
            self.gettingACurrentBatchOfGifs = true
            
            GSNetworkManager.getGiphs(searchTerm:searchTerm, completion: { (status, records) in
                
                if status {
                    self.updateModelDataWith(newGifs: records)
                    self.downloadAllImageData()
                }
                
            })
            return true
        }
        
        return false
    }
    
    private func downloadAllImageData() {
        
        var operationsCompleted:Int = 0
        
        for index in 0..<gifs.count {
            
            guard let url:URL = gifs[index]["url"] as? URL else {
                continue
            }
            
            let operation:BlockOperation = BlockOperation( block: {
                GSNetworkManager.downloadImageData(url: url, completion: {
                    (status, dataForImage) in
                    if index < self.gifs.count {
                        if status {
                            let animatedImage:FLAnimatedImage = FLAnimatedImage(animatedGIFData: dataForImage, optimalFrameCacheSize: 3, predrawingEnabled: false)
                            print(index)
                            print(url)
                            self.gifs[index]["animatedImage"] = animatedImage
                        } else {
                            print("fail")
                        }
                        operationsCompleted += 1
                        if operationsCompleted == self.gifs.count {
                            self.addNewGifs()
                        }
                    }
                })
            })
            
            queue.addOperation(operation)
            
        }
        
    }
    
    //MARK: Helper Methods
    
    func convertImagesForThisData(allImageData:[Int: URL]) {
        
        var operationsCompleted:Int = 0
        
        for key in allImageData.keys {
            
            guard let url:URL = allImageData[key] else {
                continue
            }
            
            let operation:BlockOperation = BlockOperation( block: {
                GSNetworkManager.downloadImageData(url: url, completion: {
                    (status, dataForImage) in
                    
                        if status {
                            let animatedImage:FLAnimatedImage = FLAnimatedImage(animatedGIFData: dataForImage, optimalFrameCacheSize: 3, predrawingEnabled: false)
                            self.gifsForVisibleCells[key] = animatedImage
                        } else {
                            print("fail")
                        }
                        operationsCompleted += 1
                        if operationsCompleted == allImageData.count {
                            self.addNewGifsForVisibleCells()
                        }
                })
            })
            
            queue.addOperation(operation)
            
        }
    }
    
    private func updateModelDataWith(newGifs:[[String:AnyObject]]) {
        gifs.append(contentsOf: newGifs)
    }
    
}

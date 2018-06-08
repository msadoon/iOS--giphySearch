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
    
    public init() {
        self.coreDataStack = GSCoreDataStack.sharedInstance
        self.managedContext = coreDataStack.newBackgroundContext
    }
    
    //MARK: Core Data Operations
    
    func addNewGifs() {
        
        for gif in gifs {
            
            if let foundGifName:String = gif["name"] as? String,
                let foundGifIDString:String = gif["id"] as? String,
                let foundGifImage:FLAnimatedImage = gif["animatedImage"] as? FLAnimatedImage,
                let foundGifURL:URL = gif["url"] as? URL {
                let newGif:GSGif = GSGif(context: self.managedContext)
                newGif.name = foundGifName
                newGif.id = foundGifIDString
                newGif.image = foundGifImage
                newGif.url = foundGifURL
                newGif.searchTerm = GSNetworkManager.currentSearchTerm
            }
            
        }
        
        gifs = []
        
        if self.managedContext.hasChanges {
            self.coreDataStack.saveContext(context: managedContext)
        }
        
        NotificationCenter.default.post(name: .newGifsDownloaded, object: nil)
        
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
    
    //MARK: Network

    func getAllGiphJSONData(searchTerm:String) {
        GSNetworkManager.getGiphs(searchTerm:searchTerm, completion: { (status, records) in

            if status {
                self.updateModelDataWith(newGifs: records)
                self.downloadAllImageData()
            }

        })
    }

    private func updateModelDataWith(newGifs:[[String:AnyObject]]) {
        gifs.append(contentsOf: newGifs)
    }

    private func downloadAllImageData() {
        
        var imagesDownloaded = 0
        
        for index in 0..<gifs.count {
            
            guard let url:URL = gifs[index]["url"] as? URL else {
                continue
            }
            
            GSNetworkManager.downloadImageData(url: url, completion: {
                (status, dataForImage) in
                if index < self.gifs.count {
                    if status {
                        let animatedImage:FLAnimatedImage = FLAnimatedImage(gifData: dataForImage)
                        self.gifs[index]["animatedImage"] = animatedImage
                        imagesDownloaded += 1
                        if (imagesDownloaded == (self.gifs.count)) { self.addNewGifs() }
                    } else {
                        imagesDownloaded += 1
                        if (imagesDownloaded == (self.gifs.count)) { self.addNewGifs() }
                    }
                }
            })
            
        }
        
    }
    
}

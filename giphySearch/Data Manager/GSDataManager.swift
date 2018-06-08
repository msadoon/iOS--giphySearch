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
    
    //MARK: Core Data
    
    func saveNewGifs() {
        
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
                        if (imagesDownloaded == (self.gifs.count)) { self.saveNewGifs() }
                    } else {
                        imagesDownloaded += 1
                        if (imagesDownloaded == (self.gifs.count)) { self.saveNewGifs() }
                    }
                }
            })
            
        }
        
    }
    
}

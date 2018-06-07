//
//  GSDataManager.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-07.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation
import FLAnimatedImage

class GSDataManager {
    
    static let sharedInstance:GSDataManager = GSDataManager()
    
    private var gifs:[GSGif] = []
    
    func getAllGiphJSONData(searchTerm:String) {
        GSNetworkManager.getGiphs(searchTerm:searchTerm, completion: { (status, records) in
            
            if status {
                self.updateModelDataWith(newGifs: records)
                self.downloadAllImageData()
            }
            
        })
    }
    
    private func updateModelDataWith(newGifs:[GSGif]) {
        gifs.append(contentsOf: newGifs)
    }
    
    func allGifsForCurrentSearchTerm() -> [GSGif] {
        return gifs
    }
    
    private func downloadAllImageData() {
        
        var countOfSuccessfullyDownloadedGifs = 0
        
        for index in 0..<gifs.count {
            GSNetworkManager.downloadImageData(url: gifs[index].url, completion: {
                (status, dataForImage) in
                
                if status {
                    let animatedImage:FLAnimatedImage = FLAnimatedImage(gifData: dataForImage)
                    self.gifs[index].image = animatedImage
                    countOfSuccessfullyDownloadedGifs += 1
                }
                
                if countOfSuccessfullyDownloadedGifs == (self.gifs.count - 1) {
                    NotificationCenter.default.post(name: .newGifsDownloaded, object: nil)
                }
                
            })
            
        }
        
        
    }
}

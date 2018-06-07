//
//  NetworkManager.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-06.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation
import FLAnimatedImage

enum GiphyAPI:String {
    
    case searchTermBaseURL = "https://api.giphy.com/v1/gifs/search?api_key=98bt0IFeHjWUyPLhaxO8gI4G5LptY6fV&limit=20&offset=0&rating=G&lang=en&q="
}

public class GSNetworkManager {
    
    static func getGiphs(searchTerm:String, completion: @escaping (_ status: Bool, _ records:[GSGif])->()) {
        
        guard let urlForSearch:URL = URL(string: GiphyAPI.searchTermBaseURL.rawValue + searchTerm) else {
            completion(false, [])
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlForSearch) { data, response, error in
            
            if error != nil {
                completion(false, [])
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    completion(false, [])
                    return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let data = data {
                    //parse data in model
                
                guard let jsonData:[String:AnyObject] = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as! [String : AnyObject],
                      let completeDataDictionary:[[String:AnyObject]] = jsonData["data"] as? [[String:AnyObject]] else {
                    completion(false, [])
                    return
                }
                
                var allRecords:[GSGif] = []
                
                for dictionary in completeDataDictionary {
                    
                    if let foundGiphyObjectID:String = dictionary["id"] as? String,
                        let foundGiphyObjectTitle:String = dictionary["title"] as? String,
                        let foundGiphyObjectAllImages:[String:[String:AnyObject]] = dictionary["images"] as? [String:[String:AnyObject]],
                        let foundGiphyObjectDownsized:[String:AnyObject] = foundGiphyObjectAllImages["downsized"],
                        let foundGiphyObjectDownsizeURL:String = foundGiphyObjectDownsized["url"] as? String,
                        let giphyObjectDownsizedURL:URL = URL(string: foundGiphyObjectDownsizeURL)
                    {
                        
                        let newGSGifObject:GSGif = GSGif(id: foundGiphyObjectID, name: foundGiphyObjectTitle, url: giphyObjectDownsizedURL)
                        allRecords.append(newGSGifObject)
                        
                    }
                    
                }
                
                completion(true, allRecords)
                return
            }
        }
        
        task.resume()
        
    }
    
    static func downloadImageData(url: URL, completion: @escaping (_ status: Bool, _ dataForImage:Data?) -> ()) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if error != nil {
                completion(false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    completion(false, nil)
                    return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "image/gif",
                let data = data {
                
                completion(true, data)
                return
            }
        }
        
        task.resume()
        
    }
    
}

//SDWebImageCodersManager.sharedInstance().addCoder(SDWebImageGIFCoder.shared())
////        SDWebImageDownloader.shared().shouldDecompressImages
//
////MARK: Helper functions:
//private func getImageDataAndUpdateCell(forURL: URL, indexPath:IndexPath) {
//    
//    //        SDWebImageScaleDownLargeImages = 1 << 12,
//    //        SDWebImageQueryDataWhenInMemory = 1 << 13,
//    //        SDWebImageQueryDiskSync = 1 << 14,
//    SDWebImageManager.shared().loadImage(with: forURL, options: [.queryDataWhenInMemory, .scaleDownLargeImages, .continueInBackground], progress: nil, completed: {
//        (image : UIImage?, imageData: Data?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
//        if finished {
//            //                if (cacheType == .none || cacheType == .disk) {
//            DispatchQueue.main.async {
//                if let cellStillVisible = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell
//                {
//                    DispatchQueue.global(qos: .background).async {
//                        if let imageDataFound = image?.sd_imageData(),
//                            let animatedImage:FLAnimatedImage = FLAnimatedImage(gifData: imageDataFound) {
//                            DispatchQueue.main.async {
//                                cellStillVisible.imageView.animatedImage = animatedImage
//                                cellStillVisible.imageView.setNeedsDisplay()
//                            }
//                        }
//                    }
//                }
//            }
//            //                } else {
//            //                    DispatchQueue.main.async {
//            //                        if let cellStillVisible = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell,
//            //                            let animatedImage:FLAnimatedImage = FLAnimatedImage {
//            //                            cellStillVisible.imageView.animatedImage = animatedImage
//            //                            cellStillVisible.imageView.setNeedsDisplay()
//            //                        }
//            //                    }
//            //                }
//        }
//        
//    })
//    //        DispatchQueue.main.async {
//    //            if let cellStillVisible = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell {
//    //                cellStillVisible.imageView.sd_setImage(with: forURL, placeholderImage: UIImage(named:"placeholder"), options: .continueInBackground, completed: { (image, error, cacheType, imageURL) in
//    //                    if image != nil {
//    //                        cellStillVisible.setNeedsLayout()
//    //                        print(imageURL)
//    //                    } else {
//    //                        print("not found")
//    //                    }
//    //                })
//    //            }
//    //
//}
//
//
//print(indexPath)
//cell.imageView.animatedImage = nil
//cell.imageView.sd_imageTransition = .fade
////call an async block to get the image data
//
//if let createdURLForString = URL(string: self.gifs[indexPath.row].urlString) {
//    getImageDataAndUpdateCell(forURL: createdURLForString, indexPath: indexPath)
//}

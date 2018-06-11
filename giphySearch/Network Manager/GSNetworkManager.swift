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
    
    case searchTermBaseURL = "https://api.giphy.com/v1/gifs/search?api_key=98bt0IFeHjWUyPLhaxO8gI4G5LptY6fV&rating=G&lang=en&q="
    case searchTermOffset = "&offset="
    case searchTermLimit = "&limit="
}

public class GSNetworkManager {
    
    static var currentSearchTerm:String = ""
    static private var currentOffset = 0
    static var currentLimit = 20
    
    static func getGiphs(searchTerm:String, completion: @escaping (_ status: Bool, _ records:[[String:AnyObject]])->()) {
        
        guard let percentEncodedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let urlForSearch:URL = URL(string: GiphyAPI.searchTermBaseURL.rawValue + percentEncodedString + GiphyAPI.searchTermOffset.rawValue + "\(currentOffset)" + GiphyAPI.searchTermLimit.rawValue + "\(currentLimit)") else {
            completion(false, [])
            return
        }
        print(urlForSearch)
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
                
                var allRecords:[[String:AnyObject]] = []
                currentSearchTerm = searchTerm
                
                for dictionary in completeDataDictionary {
                    
                    if let foundGiphyObjectID:AnyObject = dictionary["id"],
                        let foundGiphyObjectTitle:AnyObject = dictionary["title"],
                        let foundGiphyObjectAllImages:[String:[String:AnyObject]] = dictionary["images"] as? [String:[String:AnyObject]],
                        let foundGiphyObjectDownsized:[String:AnyObject] = foundGiphyObjectAllImages["downsized"],
                        let foundGiphyObjectDownsizedWidth:String = foundGiphyObjectDownsized["width"] as? String,
                        let foundGiphyObjectDownsizedHeight:String = foundGiphyObjectDownsized["height"] as? String,
                        let foundGiphyObjectDownsizeURL:String = foundGiphyObjectDownsized["url"] as? String,
                        let giphyObjectDownsizedURL:URL = URL(string: foundGiphyObjectDownsizeURL)
                    {
                        
                        allRecords.append(["id": foundGiphyObjectID, "name": foundGiphyObjectTitle, "url" : giphyObjectDownsizedURL as AnyObject, "width" : foundGiphyObjectDownsizedWidth as AnyObject, "height": foundGiphyObjectDownsizedHeight as AnyObject])
                        
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
    
    //MARK: Helper Methods
    
    static func setCurrentOffsetForSearchTerm(newOffset: Int) {
        currentOffset = newOffset
    }
    
}

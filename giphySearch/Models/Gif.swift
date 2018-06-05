//
//  Gif.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-05.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit

struct Gif {
    
    var caption: String
    var comment: String
    var image: UIImage
    
    init(caption: String, comment: String, image: UIImage) {
        self.caption = caption
        self.comment = comment
        self.image = image
    }
    
    init?(dictionary: [String: String]) {
        guard let caption = dictionary["Caption"], let comment = dictionary["Comment"], let photo = dictionary["Gif"],
            let image = UIImage(named: photo) else {
                return nil
        }
        self.init(caption: caption, comment: comment, image: image)
    }
    
    static func allGifs() -> [Gif] {
        var gifs = [Gif]()
        guard let URL = Bundle.main.url(forResource: "Gifs", withExtension: "plist"),
            let gifsFromPlist = NSArray(contentsOf: URL) as? [[String:String]] else {
                return gifs
        }
        for dictionary in gifsFromPlist {
            if let gif = Gif(dictionary: dictionary) {
                gifs.append(gif)
            }
        }
        return gifs
    }
    
}

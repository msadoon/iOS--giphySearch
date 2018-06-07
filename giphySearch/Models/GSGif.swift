//
//  GSGif.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-05.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit
import FLAnimatedImage

struct GSGif {
    
    var id: String
    var name: String
    var rank: Int
    var url: URL
    var image: FLAnimatedImage?
    
    init(id: String, name: String, url: URL) {
        self.id = id
        self.rank = 0
        self.url = url
        self.name = name
    }
    
}

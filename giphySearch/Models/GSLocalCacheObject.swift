//
//  GSLocalCacheObject.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-10.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation
import FLAnimatedImage

struct GSLocalCacheObject:Equatable {
    var timeStamp:TimeInterval
    var image:FLAnimatedImage?
    
    init(_ timeStamp: TimeInterval, image: FLAnimatedImage) {
        self.timeStamp = timeStamp
        self.image = image
    }
    
    static func == (lhs: GSLocalCacheObject, rhs: GSLocalCacheObject) -> Bool {
        return
            lhs.timeStamp == rhs.timeStamp
    }
}

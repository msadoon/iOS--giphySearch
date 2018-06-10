//
//  Notification+Name.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-07.
//  Copyright © 2018 msadoon. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let newGifsDownloaded = Notification.Name("newGifs")
    static let gifUpdatedRank = Notification.Name("rankUpdate")
    static let deletedAllGifsForSearchTerm = Notification.Name("deletedAll")
    static let convertedAllImages = Notification.Name("convertedDataToFLAnimatedImage")
    
}

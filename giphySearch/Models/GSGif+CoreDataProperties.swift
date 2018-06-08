//
//  GSGif+CoreDataProperties.swift
//  
//
//  Created by Mubarak Sadoon on 2018-06-07.
//
//

import Foundation
import CoreData
import FLAnimatedImage

extension GSGif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GSGif> {
        return NSFetchRequest<GSGif>(entityName: "GSGif")
    }

    @NSManaged public var id: String
    @NSManaged public var image: FLAnimatedImage?
    @NSManaged public var name: String?
    @NSManaged public var rank: Int32
    @NSManaged public var url: URL?
    @NSManaged public var searchTerm: String?
    
}

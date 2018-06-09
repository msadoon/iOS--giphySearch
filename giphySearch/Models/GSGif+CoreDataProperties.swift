//
//  GSGif+CoreDataProperties.swift
//  
//
//  Created by Mubarak Sadoon on 2018-06-09.
//
//

import Foundation
import CoreData
import FLAnimatedImage

extension GSGif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GSGif> {
        return NSFetchRequest<GSGif>(entityName: "GSGif")
    }

    @NSManaged public var height: Int32
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var name: String?
    @NSManaged public var rank: Int32
    @NSManaged public var searchTerm: String?
    @NSManaged public var url: URL?
    @NSManaged public var width: Int32

}

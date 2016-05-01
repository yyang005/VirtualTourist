//
//  Photo.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/17/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var filePath: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
       super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = dictionary["title"] as! String
        self.filePath = dictionary["url_m"] as! String
    }
}
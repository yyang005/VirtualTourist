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
    @NSManaged var imageURL: String
    @NSManaged var pin: Pin?
    @NSManaged var filePath: String
    
    var imageData: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
       super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = dictionary["title"] as! String
        self.imageURL = dictionary["url_m"] as! String
        let imageURL = NSURL(string: self.imageURL)!
        self.filePath = getFilePath(imageURL.lastPathComponent!)
    }
    
    func getFilePath(urlString: String) -> String {
        let documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let filePath = documentDirectoryURL?.URLByAppendingPathComponent(urlString).path
        return filePath!
    }
}
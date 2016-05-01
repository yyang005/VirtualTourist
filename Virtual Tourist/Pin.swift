//
//  Pin.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/17/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
    }
}
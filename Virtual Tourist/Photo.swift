//
//  Photo.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/17/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class Photo {
    var title: String
    var filePath: String
    var pin: Pin?
    
    init(dictionary: [String: AnyObject]){
        self.title = dictionary["title"] as! String
        self.filePath = dictionary["url_m"] as! String
    }
}
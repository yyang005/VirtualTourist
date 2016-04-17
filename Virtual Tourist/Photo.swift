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
    let pin: Pin
    
    init(title: String, filePath: String, pin: Pin){
        self.title = title
        self.filePath = filePath
        self.pin = pin
    }
}
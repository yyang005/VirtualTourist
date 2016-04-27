//
//  Pin.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/17/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class Pin {
    var latitude: Double
    var longitude: Double
    var photos: [Photo] = [Photo]()
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
}
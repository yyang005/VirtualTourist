//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/17/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

extension FlickrClient {
    struct Constants {
        
        //MARK: Flickr URLs
        
        static let ApiSchem = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
        
        //MARK: maximum number of photos to be saved
        
        //static let MaxNumPhotos: Int = 21
    }
    
    struct FlickrParameterKey {
        static let ApiKey = "api_key"
        static let Method = "method"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Format = "format"
        static let Extras = "extras"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    struct FlickrParameterValue {
        static let ApiKey = "7ae4bf4fa96bef36f7f403c5f4c5d59d"
        static let SearchMethod = "flickr.photos.search"
        static let ResponseFormat = "json"
        static let MediumURL = "url_m"
        static let DisableJSONCallback = "1"
        static let PerPage = "21"
    }
    
    struct FlickrResponseKey {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
}
//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/17/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class FlickrClient {
    lazy var session = NSURLSession.sharedSession()
    
    static let sharedInstance = FlickrClient()
    
    // MARK: all purpose data task methods
    
    func taskForGetMethod(method: [String: String], completionHandlerForGet: (results: AnyObject?, error: String?) -> Void) -> NSURLSessionDataTask{
        let url = urlFromMethod(method)
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandlerForGet(results: nil, error: error!.description)
                return
            }

            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForGet(results: nil, error: "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                completionHandlerForGet(results: nil, error: "No data returned with your request")
                return
            }
            self.parseData(data, completionHandler: completionHandlerForGet)
        }
        
        task.resume()
        return task
    }
    
    func parseData(data: NSData, completionHandler: (results: AnyObject?, error: String?) -> Void) {
        let parseResults: AnyObject?
        do {
            try parseResults = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandler(results: parseResults, error: nil)
        }catch {
            completionHandler(results: nil, error: "Could not parse data as JSON: '\(data)'")
        }
    }
    
    func urlFromMethod(method: [String: String]) -> NSURL{
        let urlComponent = NSURLComponents()
        urlComponent.scheme = FlickrClient.Constants.ApiSchem
        urlComponent.host = FlickrClient.Constants.ApiHost
        urlComponent.path = FlickrClient.Constants.ApiPath
        var queryItems = [NSURLQueryItem]()
        for (key, value) in method {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        urlComponent.queryItems = queryItems
        let url = urlComponent.URL!
        return url
    }
    
    func taskForImage(imagePath: String, downloadImageCompletionHandler: (data: NSData?, error: String?) -> Void) -> NSURLSessionTask{
        let request = NSURLRequest(URL: NSURL(string: imagePath)!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                downloadImageCompletionHandler(data: nil, error: error!.description)
                return
            }
            downloadImageCompletionHandler(data: data, error: nil)
        }
        task.resume()
        return task
    }
    
    // Convinience methods to wrap core network methods
    
    func searchFlickrPhotosByLocation(latitude: Double, longitude: Double, searchCompletionHandler: (results: [[String: AnyObject]]?, error: String?) -> Void){
        let method: [String: String] = [
            FlickrParameterKey.ApiKey: FlickrParameterValue.ApiKey,
            FlickrParameterKey.Method: FlickrParameterValue.SearchMethod,
            FlickrParameterKey.Latitude: "\(latitude)",
            FlickrParameterKey.Longitude: "\(longitude)",
            FlickrParameterKey.Format: FlickrParameterValue.ResponseFormat,
            FlickrParameterKey.Extras: FlickrParameterValue.MediumURL,
            FlickrParameterKey.NoJSONCallback: FlickrParameterValue.DisableJSONCallback
        ]
        
        taskForGetMethod(method) { (results, error) -> Void in
            guard error == nil else {
                searchCompletionHandler(results: nil, error: error!)
                return
            }
            guard let results = results else {
                searchCompletionHandler(results: nil, error: "no photos returned")
                return
            }
            guard let photoDictionary = results[FlickrResponseKey.Photos] as? [String: AnyObject] else {
                searchCompletionHandler(results: nil, error: "could not find the key: \(FlickrResponseKey.Photos)")
                return
            }
            
            guard let totalPages = photoDictionary[FlickrResponseKey.Pages] as? Int else {
                searchCompletionHandler(results: nil, error: "could not find the key: \(FlickrResponseKey.Pages)")
                return
            }
            let pageLimit = min(totalPages, 40)
            let pageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            self.searchFlickrPhotosByLocation(latitude, longitude: longitude, withPageNumber: pageNumber, searchWithPageCompletionHandler: { (results, error) -> Void in
                    searchCompletionHandler(results: results, error: error)
            })
        }
    }
    
    func searchFlickrPhotosByLocation(latitude: Double, longitude: Double, withPageNumber: Int, searchWithPageCompletionHandler: (results: [[String: AnyObject]]?, error: String?) -> Void){
        let method: [String: String] = [
            FlickrParameterKey.ApiKey: FlickrParameterValue.ApiKey,
            FlickrParameterKey.Method: FlickrParameterValue.SearchMethod,
            FlickrParameterKey.Latitude: "\(latitude)",
            FlickrParameterKey.Longitude: "\(longitude)",
            FlickrParameterKey.Format: FlickrParameterValue.ResponseFormat,
            FlickrParameterKey.Extras: FlickrParameterValue.MediumURL,
            FlickrParameterKey.NoJSONCallback: FlickrParameterValue.DisableJSONCallback,
            FlickrParameterKey.Page: "\(withPageNumber)"
        ]
        
        taskForGetMethod(method) { (results, error) -> Void in
            guard error == nil else {
                searchWithPageCompletionHandler(results: nil, error: error!)
                return
            }
            guard let results = results else {
                searchWithPageCompletionHandler(results: nil, error: "no photos returned")
                return
            }
            guard let photoDictionary = results[FlickrResponseKey.Photos] as? [String: AnyObject] else {
                searchWithPageCompletionHandler(results: nil, error: "could not find the key: \(FlickrResponseKey.Photos)")
                return
            }
            guard let photoArray = photoDictionary[FlickrResponseKey.Photo] as? [[String: AnyObject]] else {
                searchWithPageCompletionHandler(results: nil, error: "could not find the key: \(FlickrResponseKey.Photo)")
                return
            }
            
            searchWithPageCompletionHandler(results: photoArray, error: nil)
        }
    }

}
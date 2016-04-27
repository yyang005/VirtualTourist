//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/7/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var isEditMode = false
    
    var label: UILabel?
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressed = UILongPressGestureRecognizer(target: self, action: "handleLongPressed:")
        longPressed.minimumPressDuration = 2
        mapView.addGestureRecognizer(longPressed)
        createLabel()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "barButtonItemClicked")
        mapView.delegate = self
        
        loadMapViewSettings(mapView)
    }
    
    
    // MARK: IB Actions
    
    func barButtonItemClicked(){
        isEditMode = !isEditMode
        if isEditMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "barButtonItemClicked")
            view.frame.origin.y -= 40
            view.superview?.addSubview(label!)
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "barButtonItemClicked")
            view.frame.origin.y += 40
            label!.removeFromSuperview()
        }
    }
    
    func createLabel(){
        let x = self.view.frame.origin.x
        let y = self.view.frame.origin.y + view.frame.height - 40
        let rect = CGRect(x: x, y: y, width: view.frame.width, height: 40)
        label = UILabel(frame: rect)
        label!.center = CGPointMake(view.frame.width/2, view.frame.height-20)
        label!.text = "Tap pins to delete"
        label!.textAlignment = .Center
        label!.textColor = UIColor.whiteColor()
        label!.backgroundColor = UIColor.redColor()
    }
    
    func handleLongPressed(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let location = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }

    // MARK: MapView delegates
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        if isEditMode {
            mapView.removeAnnotation(view.annotation!)
        }else{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoCollection") as! PhotoCollectionViewController
            let lat = view.annotation?.coordinate.latitude
            let long = view.annotation?.coordinate.longitude
            vc.pin = Pin(latitude: lat!, longitude: long!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapViewSettings(mapView)
    }
    
    func saveMapViewSettings(mapView: MKMapView){
        let defaults = NSUserDefaults.standardUserDefaults()
        let dictionary = ["latitude": mapView.region.center.latitude, "longitude": mapView.region.center.longitude,
                            "spanLatDelta": mapView.region.span.latitudeDelta, "spanLongDelta": mapView.region.span.longitudeDelta]
        
        defaults.setObject(dictionary, forKey: "location")
        defaults.setBool(true, forKey: "firstLoad")
    }
    
    func loadMapViewSettings(mapView: MKMapView){
        let defaults = NSUserDefaults.standardUserDefaults()
        let loaded = defaults.boolForKey("firstLoad")
        if loaded {
            let dic = defaults.objectForKey("location")!
            let lat = dic["latitude"] as! Double
            let long = dic["longitude"] as! Double
            let spanLatDelta = dic["spanLatDelta"] as! Double
            let spanLongDelta = dic["spanLongDelta"] as! Double
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let span = MKCoordinateSpan(latitudeDelta: spanLatDelta, longitudeDelta: spanLongDelta)
            let region = MKCoordinateRegionMake(center, span)
            mapView.setRegion(region, animated: true)
        }
    }
}


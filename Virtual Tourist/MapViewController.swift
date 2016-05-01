//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/7/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
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
        
        var pins = [Pin]()
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            pins = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        }catch(let error) {
            print(error)
        }
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: Core data convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext(){
        CoreDataStackManager.sharedInstance().saveContext()
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
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let location = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let _ = Pin(latitude: location.latitude, longitude: location.longitude, context: sharedContext)
            saveContext()
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: MapView delegates
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        mapView.deselectAnnotation(view.annotation, animated: true)
        if isEditMode {
            mapView.removeAnnotation(view.annotation!)
        }else{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoCollection") as! PhotoCollectionViewController
            let lat = view.annotation?.coordinate.latitude
            let long = view.annotation?.coordinate.longitude
            
            let fetchRequest = NSFetchRequest(entityName: "Pin")
            //fetchRequest.predicate = NSPredicate(format: "latitude = %@, longitude = %@", lat!, long!)
            do {
                let pins = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
                vc.pin = pins[0]
                self.navigationController?.pushViewController(vc, animated: true)
            }catch(let error) {
                print(error)
            }
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
    
    // MARK: fetch results controller delegate methods
    
    
}


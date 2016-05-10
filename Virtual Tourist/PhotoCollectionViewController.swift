//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/14/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var noPhotoLabel: UILabel!
    
    var pin: Pin?
    let client = FlickrClient.sharedInstance
    
    var selectedIndexPaths = [NSIndexPath]()
    var insertIndexPaths: [NSIndexPath]!
    var deleteIndexPaths: [NSIndexPath]!
    var isDelete = false
    
    // MARK: IB actions
    
    @IBAction func newCollection(sender: AnyObject) {
        if isDelete {
            update()
            isDelete = false
        }else {
            grabNewPhotos()
        }
    }
    
    //MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        let dimensionX = (view.frame.size.width - (2 * space)) / 3.0
        let dimensionY = dimensionX
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimensionX, dimensionY)
        button.enabled = false
        
        do {
            try fetchedResultsController.performFetch()
            if pin!.photos?.count > 0 {
                button.enabled = true
            }
        }catch(let error){
            let error = error as NSError
            alert(error.description)
        }
        
        fetchedResultsController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if pin!.photos?.count == 0 {
            fetchPhotosFromFlickr()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let pin = pin {
            dropPin(pin)
        }
    }
    
    //MARK: helper methods
    
    func dropPin(pin: Pin){
        let center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
    }
    
    func removeSelectedPhotos() {
        let photos = fetchedResultsController.fetchedObjects as! [Photo]
        if selectedIndexPaths.count > 0 {
            for indexPath in selectedIndexPaths {
                let photo = photos[indexPath.row]
                sharedContext.deleteObject(photo)
                
            }
            saveContext()
        }
    }
    
    func update() {
        button.titleLabel!.text = "New Collection"
        removeSelectedPhotos()
    }
    
    //MARK: fetch new photos from flickr
    func grabNewPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        saveContext()
        fetchPhotosFromFlickr()
    }
    
    func fetchPhotosFromFlickr() {
        client.searchFlickrPhotosByLocation((pin?.latitude)!, longitude: (pin?.longitude)!) { (results, error) -> Void in
            guard error == nil else {
                self.alert(error!)
                return
            }
            
            if let photoArray = results {
                if photoArray.count == 0 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.collectionView.hidden = true
                        self.noPhotoLabel.hidden = false
                        self.noPhotoLabel!.text = "This pin has no photos"
                    })
                    return
                }
                print(photoArray)
                let numPhotos = min(photoArray.count, FlickrClient.Constants.MaxNumPhotos)
                for i in 0...numPhotos {
                    let photo = Photo(dictionary: photoArray[i], context: self.sharedContext)
                    
                    // In core data we use the relationship. We set the photo's pin property
                    photo.pin = self.pin
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.button.enabled = true
                    //self.collectionView.reloadData()
                })
                self.saveContext()
            }
        }
    }
    
    // MARK: Core data convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext(){
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()

    //MARK: Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let sectionInfo = fetchedResultsController.sections!
        return sectionInfo.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let imagePath = photo.filePath
        
        cell.layer.cornerRadius = 5
        
        cell.imageView.backgroundColor = UIColor.lightGrayColor()
        cell.activityIndicator.startAnimating()
        client.taskForImage(imagePath) { (data, error) -> Void in
            
            guard error == nil else {
                print(error)
                return
            }
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.activityIndicator.stopAnimating()
                cell.imageView.image = image
            })
        }
        return cell
    }
    
    //MARK: collection view delegate methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionCell
        
        let index = selectedIndexPaths.indexOf(indexPath)
        if let index = index {
            selectedIndexPaths.removeAtIndex(index)
            selectCell.imageView.alpha = 1.0
        }else {
            selectedIndexPaths.append(indexPath)
            selectCell.imageView.alpha = 0.25
        }
        
        if selectedIndexPaths.count > 0{
            if !isDelete {
                isDelete = true
                button.titleLabel!.text = "Delete"
            }
        }else{
            button.titleLabel!.text = "New Collection"
            isDelete = false
        }
    }
    
    // MARK: fetch results controller delegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertIndexPaths = [NSIndexPath]()
        deleteIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertIndexPaths.append(newIndexPath!)
        case .Delete:
            deleteIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.insertItemsAtIndexPaths(self.insertIndexPaths)
            self.collectionView.deleteItemsAtIndexPaths(self.deleteIndexPaths)
            }, completion: nil)
    }
}

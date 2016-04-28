//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by ying yang on 4/14/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import MapKit

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var noPhotoLabel: UILabel!
    
    var pin: Pin?
    let client = FlickrClient.sharedInstance
    
    var selectedIndexPaths = [NSIndexPath]()
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        button.enabled = false
        client.searchFlickrPhotosByLocation((pin?.latitude)!, longitude: (pin?.longitude)!) { (results, error) -> Void in
            guard error == nil else {
                print(error)
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
                for elem in photoArray {
                    let photo = Photo(dictionary: elem)
                    self.pin!.photos.append(photo)
                }
                _ = photoArray.map() { (dictionary: [String : AnyObject]) -> Photo in
                    let photo = Photo(dictionary: dictionary)
                    
                    // We associate this movie with it's actor by appending it to the array
                    // In core data we use the relationship. We set the movie's actor property
                    self.pin!.photos.append(photo)
                    
                    return photo
                }

            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.button.enabled = true
                self.collectionView.reloadData()
            })
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
        if selectedIndexPaths.count > 0 {
            for index in selectedIndexPaths {
                pin?.photos.removeAtIndex(index.row)
            }
        }
    }
    
    func update() {
        button.titleLabel!.text = "New Collection"
        removeSelectedPhotos()
        collectionView.deleteItemsAtIndexPaths(selectedIndexPaths)
    }
    
    //TODO: fetch new photos from flickr
    func grabNewPhotos() {
        
    }
    
    //MARK: Collection view data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin!.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionCell
        let imagePath = pin?.photos[indexPath.row].filePath
        
        cell.layer.cornerRadius = 5
        
        cell.imageView.backgroundColor = UIColor.lightGrayColor()
        cell.activityIndicator.startAnimating()
        client.taskForImage(imagePath!) { (data, error) -> Void in
            
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
}

//
//  ViewController.swift
//  MiniMapp
//
//  Created by Emannuel Carvalho on 5/14/16.
//  Copyright © 2016 Emannuel Carvalho. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: -23, longitude: -46)
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureLocationManager()
    }
    
    func configureMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        centerMapView()
        addLongPressGestureRecognizer()
    }
    
    func centerMapView() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addLongPressGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: "didCaptureLongPress:")
        gesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gesture)
    }
    
    func didCaptureLongPress(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if placemarks != nil && placemarks?.count > 0 {
                let place = placemarks![0]
                let city = place.locality
                let street = place.thoroughfare
                let number = place.subThoroughfare
                
                if city != nil &&
                street != nil &&
                number != nil {
                    let address = "\(street!), \(number!) - \(city!)"
                    self.addAnnotationToCoordinate(coordinate, address: address)
                }
            }
        }
    }
    
    func addAnnotationToCoordinate(coordinate: CLLocationCoordinate2D, address: String) {
        let annotation        = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title      = address
        annotation.subtitle   = "Just some fun text 😎"
        mapView.addAnnotation(annotation)
    }
    
    func configureLocationManager() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - LocationManager delegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {

            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.image = UIImage(named:"xaxas")
            anView?.canShowCallout = true
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView?.annotation = annotation
        }
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: "img")
        
        // .. configure
        anView?.addSubview(imageView)
        return anView
    }
    
    
    
}


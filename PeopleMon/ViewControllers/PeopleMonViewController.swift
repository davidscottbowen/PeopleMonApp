//
//  PeopleMonViewController.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/6/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit
import MapKit

class PeopleMonViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var updatingLocation = true
    var latitudeDelta = 0.002
    var longitudeDelta = 0.002
    var checkInTimer: Timer!
    
    var nearbyPeople = [People]()
    var previousLocation: CLLocation?
    var userCircles = [MKOverlay]()
    var selectedNearbyPeopleMon = [MKOverlay]()
    
    var annotations: [MapPin] = []
    var overlay: MKOverlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        checkIn()
        getPeople()
        
        checkInTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(PeopleMonViewController.checkIn), userInfo: nil, repeats: true)
    }
    
    func convertBase64ToImage(base64String: String?) -> UIImage? {
        
        if let base64String = base64String, let photoData = NSData(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: photoData as Data)
        }
        
        return #imageLiteral(resourceName: "blankAvatar")
    }
    
    
    func checkIn() {
        if updatingLocation == true {
            let coordinate = locationManager.location?.coordinate
            let user = People(coordinate: coordinate!)
            WebServices.shared.postObject(user, completion: { (object, error) in
            })
        }
    }
    
    func getPeople(){
        let people = People(radius: Constants.radius)
        WebServices.shared.getObjects(people) { (objects, error) in
            if let objects = objects {
                self.annotations = []
                for person in objects {
                    let pin = MapPin(people: person)
                    self.annotations.append(pin)
                }
                self.mapView.addAnnotations(self.annotations)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !WebServices.shared.userAuthTokenExists() || WebServices.shared.userAuthTokenExpired() {
            performSegue(withIdentifier: "presentLoginNoAnimation", sender: self)
        }
        previousLocation = locationManager.location
        updatePeoplemonRadar()
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePeoplemonRadar() {
        let user = People(radius: 500)
        nearbyPeople = []
        WebServices.shared.getObjects(user) { (objects, error) in
            if let objects = objects {
                for i in objects {
                    let objectLocation = CLLocation(latitude: i.latitude!, longitude: i.longitude!)
                    let distance = Double(objectLocation.distance(from: self.previousLocation!))
                    if distance >= 100.00 && distance <= 500.00 {
                        self.nearbyPeople.append(i)
                    }
                }
                self.nearbyPeople.sort(by: { (user1, user2) -> Bool in
                    let locationOfUser1 = CLLocation(latitude: user1.latitude!, longitude: user1.longitude!)
                    let distance1 = Double(locationOfUser1.distance(from: self.previousLocation!))
                    
                    let locationOfUser2 = CLLocation(latitude: user2.latitude!, longitude: user2.longitude!)
                    let distance2 = Double(locationOfUser2.distance(from: self.previousLocation!))
                    
                    return distance1 < distance2
                })
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        WebServices.shared.clearUserAuthToken()
        UserStore.shared.logout{}
        
        performSegue(withIdentifier: "presentLoginNoAnimation", sender: self)
    }
}

extension PeopleMonViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        if previousLocation == nil {
            previousLocation = location
        }
        
        let distance = Double(location.distance(from: previousLocation!))
        
        if distance > 10.0 {
            getPeople()
            updatePeoplemonRadar()
            previousLocation = location
        }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        mapView.setRegion(region, animated: true)
        
        let currentLocationOverlay = MKCircle(center: center, radius: 100)
        mapView.add(currentLocationOverlay)
        mapView.removeOverlays(userCircles)
        userCircles.append(currentLocationOverlay)
    }
}

// MARK: - CLLocationManagerDelegate
extension PeopleMonViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let currentUser = annotation as? MapPin
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView?.isEnabled = true
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            let catchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
            catchButton.setTitle(" Catch ", for: .normal)
            catchButton.backgroundColor = #colorLiteral(red: 0, green: 0.9771030545, blue: 0.043536596, alpha: 1)
            catchButton.sizeToFit()
            pinView?.leftCalloutAccessoryView = catchButton
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            imageView.image = convertBase64ToImage(base64String: currentUser?.avatar)
            pinView?.rightCalloutAccessoryView = imageView
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let selectedAnnotation = view.annotation as! MapPin
        let caughtPerson = People(caughtUserId: selectedAnnotation.userId!, radiusInMeters: 100)
        WebServices.shared.postObject(caughtPerson) { (object, error) in
        }
        mapView.removeAnnotation(view.annotation!)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        circleRenderer.lineWidth = 0.5
        circleRenderer.fillColor = UIColor(
            red: 0.5,
            green: 0.5,
            blue: 0.5,
            alpha: 0.3)
        return circleRenderer
    }
}

extension PeopleMonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Friends"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nearbyPeople.count > 0 {
            return nearbyPeople.count - 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell", for: indexPath)
        
        cell.textLabel?.text = nearbyPeople[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let center = CLLocationCoordinate2D(latitude: nearbyPeople[indexPath.row].latitude!, longitude: nearbyPeople[indexPath.row].longitude!)
        let selectedNearby = MKCircle(center: center, radius: 50)
        selectedNearbyPeopleMon.append(selectedNearby)
        mapView.add(selectedNearby)
        var _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(removeOverlay), userInfo: nil, repeats: false)
    }
    
    func removeOverlay() {
        if selectedNearbyPeopleMon.count > 0 {
            mapView.removeOverlays(selectedNearbyPeopleMon)
        }
    }
}


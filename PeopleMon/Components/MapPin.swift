//
//  MapPin.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/7/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit
import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var people: People?
    var title: String?
    var userId: String?
    var avatar: String?
    
    
    init(people: People) {
        self.people = people
        self.title = people.username
        self.userId = people.userId
        self.avatar = people.avatar
        
        if let lat = people.latitude, let long = people.longitude {
            self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
}


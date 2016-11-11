//
//  People.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/8/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit
import Alamofire
import Freddy
import MapKit

class People: NetworkModel {
    var userId: String?
    var username: String?
    var avatar: String?
    var latitude: Double?
    var longitude: Double?
    var created: String?
    var radius: Double?
    var caughtUserId: String?
    
    var requestType: RequestType = .nearby
    
    enum RequestType {
        case nearby
        case checkIn
        case caught
    }
    
    required init() {}
    
    required init(json: JSON) throws {
        self.userId = try? json.getString(at: Constants.People.userId)
        self.username = try? json.getString(at: Constants.People.userName)
        self.avatar = try? json.getString(at: Constants.People.avatar)
        self.latitude = try? json.getDouble(at: Constants.People.latitude)
        self.longitude = try? json.getDouble(at: Constants.People.longitude)
        self.created = try? json.getString(at: Constants.People.created)
    }
    
    init(radius: Double) {
        self.requestType = .nearby
        self.radius = radius
    }
    
    init(caughtUserId: String, radiusInMeters: Double) {
        self.caughtUserId = caughtUserId
        self.radius = radiusInMeters
        self.requestType = .caught
    }

    init(coordinate: CLLocationCoordinate2D) {
        self.requestType = .checkIn
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func method() -> Alamofire.HTTPMethod {
        switch requestType {
        case .nearby:
            return .get
        case .caught:
            return .get
        default:
            return .post
        }
    }
    
    func path() -> String {
        switch requestType {
        case .nearby:
            return "/v1/User/Nearby"
        case .checkIn:
            return "/v1/User/CheckIn"
        case .caught:
            return "/v1/User/Caught"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .nearby:
            params[Constants.People.radius] = radius as AnyObject?
            params[Constants.People.avatar] = avatar as AnyObject?
        case .checkIn:
            params[Constants.People.latitude] = latitude as AnyObject?
            params[Constants.People.longitude] = longitude as AnyObject?
        case .caught:
            break
        }
        return params
    }
}


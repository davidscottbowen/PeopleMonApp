//
//  Constants.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/6/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit

struct Constants {
    static let apiKey = "ApiKey"
    static let ApiKey = "iOS301november2016"
    public static let keychainIdentifier = "PeopleMonKeychain"
    public static let authTokenExpireDate = "authTokenExpireDate"
    public static let authToken = "authToken"
    static let radius = 100.00
    
    struct User {
        
        static let email = "Email"
        static let fullName = "FullName"
        static let apiKey = "ApiKey"
        static let avatarBase64 = "AvatarBase64"
        static let password = "password"
        static let token = "access_token"
        static let expiration = ".expires"
        static let userName = "username"
        static let id = "id"
        static let grantType = "grant_type"
        static let registered = "HasRegistered"
    }
    
    struct People {
        static let userId = "UserId"
        static let userName = "UserName"
        static let latitude = "Latitude"
        static let longitude = "Longitude"
        static let created = "Created"
        static let radius = "radiusInMeters"
        static let caughtUserId = "CaughtUserId"
        static let avatar = "AvatarBase64"
    }
    
    struct JSON {
        static let unknownError = "An Unknown Error Has Occurred"
        static let processingError = "There was an error processing the response"
    }

}



//
//  User.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/7/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit
import Alamofire
import Freddy

class User : NetworkModel {
    var userId: String?
    var email: String?
    var fullName: String?
    var avatarBase64: String?
    var apiKey: String?
    var password: String?
    var token: String?
    var expiration: String?
    var userName: String?
    var id: String?
    var registered: Bool?
    var radius: Double?
    
    var requestType = RequestType.login
    
    // Request Type
    enum RequestType {
        case login
        case register
        case logout
        case update
        case getUserInfo
        case catchPerson
    }

    // empty constructor
    required init() {}
    
    // create an object from JSON
    required init(json: JSON) throws {
        token = try? json.getString(at: Constants.User.token)
        expiration = try? json.getString(at: Constants.User.expiration)
        id = try? json.getString(at: Constants.User.id)
        email = try? json.getString(at: Constants.User.email)
        registered = try? json.getBool(at: Constants.User.registered)
        fullName = try? json.getString(at: Constants.User.fullName)
        avatarBase64 = try? json.getString(at: Constants.User.avatarBase64)
        token = try? json.getString(at: Constants.User.token)
        expiration = try? json.getString(at: Constants.User.expiration)
    }
    
    init(email: String, fullName: String, password: String, avatarBase64: String) {
        self.email = email
        self.fullName = fullName
        self.password = password
        self.avatarBase64 = avatarBase64
        requestType = .register
    }
    
    init(avatarBase64 : String, fullName: String) {
        self.avatarBase64 = avatarBase64
        self.fullName = fullName
        requestType = .update
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        requestType = .login
    }
    
    init(userId: String, radius: Double) {
        self.requestType = .catchPerson
        self.userId = userId
        self.radius = radius
    }
    
    // Always return HTTP.GET
    func method() -> Alamofire.HTTPMethod {
        switch requestType{
        case .getUserInfo:
            return .get
        case .update:
            return .post
        default:
            return .post
        }
    }
    
    // A sample path to a single post
    func path() -> String {
        switch requestType {
        case .register:
            return "/api/Account/Register"
        case .login:
            return "/token"
        case .logout:
            return "/api/Account/Logout"
        case .update:
            return "/api/Account/UserInfo"
        case .getUserInfo:
            return "/api/Account/UserInfo"
        case .catchPerson:
            return "/v1/User/Catch"
        }
    }
    
    // Demo object isn't being posted to a server, so just return nil
    func toDictionary() -> [String: AnyObject]? {
        
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .register:
            params[Constants.User.email] = email as AnyObject?
            params[Constants.User.fullName] = fullName as AnyObject?
            params[Constants.User.avatarBase64] = avatarBase64 as AnyObject?
            params[Constants.apiKey] = Constants.ApiKey as AnyObject?
            params[Constants.User.password] = password as AnyObject?
        case .login:
            params[Constants.User.grantType] = Constants.User.password as AnyObject?
            params[Constants.User.userName] = email as AnyObject?
            params[Constants.User.password] = password as AnyObject?
        case .update:
            params[Constants.User.fullName] = fullName as AnyObject?
            params[Constants.User.avatarBase64] = avatarBase64 as AnyObject?
        case .catchPerson:
            params[Constants.People.caughtUserId] = userId as AnyObject?
            params[Constants.People.radius] = radius as AnyObject?
        case .getUserInfo:
            break
        case .logout:
            break
        }
        return params
    }
}



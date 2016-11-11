//
//  NetworkModel.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/6/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import Foundation
import Alamofire
import Freddy

protocol NetworkModel: JSONDecodable { //a protocol is a promise that must be conformed to for an object to be this object
    init(json: JSON) throws
    init()
    
    func method() -> Alamofire.HTTPMethod
    func path() -> String
    func toDictionary() -> [String: AnyObject]?
}

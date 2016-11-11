//
//  UserStore.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/6/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import Foundation

class UserStore {
    //singleton
    static let shared = UserStore()
    
    private init() {}
    
    func login(_ loginUser: User, completion:@escaping(_ success: Bool, _ error: String?) -> Void) {
        WebServices.shared.authUser(loginUser) { (user, error) in
            if let user = user {
                WebServices.shared.setAuthToken(user.token, expiration: user.expiration)
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    
    func register(_ registerUser: User, completion:@escaping(_ success: Bool, _ error: String?) -> Void) {
        WebServices.shared.authUser(registerUser) { (user, error) in
            if let user = user {
                WebServices.shared.setAuthToken(user.token, expiration: user.expiration)
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func logout(completion:@escaping () -> Void) {
        let logoutUser = User()
        logoutUser.requestType = User.RequestType.logout
        WebServices.shared.postObject(logoutUser) { (object, error) in
            WebServices.shared.clearUserAuthToken()
            completion()
        }
    }
    
    
}



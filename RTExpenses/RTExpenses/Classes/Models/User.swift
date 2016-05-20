//
// User.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 26/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import Foundation

class User {
    
    // MARK: Properties
    var uid : String?
    var emailID : String?
    
    // MARK: Designated Initiliazers
    // Initialize from Firebase
    convenience init(authenticatedData: FAuthData) {
        self.init()
        uid = authenticatedData.uid
        emailID = authenticatedData.providerData["email"] as? String
    }
    
    
    // Initialize from arbitrary data
    convenience init(uid: String, email: String) {
        self.init()
        self.uid = uid
        self.emailID = email
    }
    
    func setUserName(userName: String) -> Bool {
        
        if  FirebaseNetworkManager.sharedInstance.currentUserRef != nil {
            
            NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "userName")
            return NSUserDefaults.standardUserDefaults().synchronize()
        }
        return false
    }
    
    func getUserName() -> String? {
        
        if  FirebaseNetworkManager.sharedInstance.currentUserRef != nil {
            
            return NSUserDefaults.standardUserDefaults().objectForKey("userName") as? String ?? ""
            
        }
        return nil
    }
}

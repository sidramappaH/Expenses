//
//  NSUserDefaults + RTExpenses.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 15/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    class func setUserNameToNSDefaults(userName: String) {
        NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "userName")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setEmailIDToNSDefaults(emailID: String) {
        NSUserDefaults.standardUserDefaults().setObject(emailID, forKey: "EmailID")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func removeUserDefaultsValues() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userName")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("EmailID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uid")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getUserID() -> String {
        return NSUserDefaults.standardUserDefaults().objectForKey("uid") as? String ?? ""
    }
    
    class  func getUserName() -> String {
        return NSUserDefaults.standardUserDefaults().objectForKey("userName") as? String ?? ""
    }
}

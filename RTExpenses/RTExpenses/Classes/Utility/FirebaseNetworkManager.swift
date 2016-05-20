//
//  FirebaseNetworkManager.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 13/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit


class FirebaseNetworkManager: NSObject {
    
    static let sharedInstance = FirebaseNetworkManager()
    let applicationRootReference = Firebase(url: "https://rtexpenses.firebaseio.com/")
    
    var currentUserRef: Firebase? {
        if let uid = NSUserDefaults.standardUserDefaults().objectForKey("uid") as? String {
            return applicationRootReference.childByAppendingPath(uid)
        }
        return nil
    }
    
    var expenseCategoryBaseUrl: Firebase? {
        return currentUserRef?.childByAppendingPath("expens-items")
    }
    
    private override init()  {
        
    }
    
    func getCategoryReferenceForTitle(title : String) -> Firebase? {
        return  expenseCategoryBaseUrl?.childByAppendingPath(title)
    }
    
    func setUserName(forUserName userName: String) {
        if let currentUserRef = currentUserRef {
            currentUserRef.childByAppendingPath("userName").setValue(userName)
        }
    }
    
    func getUserName(handler: ((String)->Void)) {
        
        guard let _ = NSUserDefaults.standardUserDefaults().objectForKey("uid") else {
            return
        }
        
        let userName = NSUserDefaults.getUserName()
        
        if !userName.isEmpty {
            handler(userName)
            return
        } else {
            if let currentUserRef = currentUserRef {
                currentUserRef.observeEventType(.Value, withBlock: { (sanpShot: FDataSnapshot!) -> Void in
                    let userName = sanpShot.value["userName"] as? String ?? ""
                    NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "userName")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    handler(userName)
                })
            }
        }
    }
    
    
    func getCategoryList(handler: ((Array<ExpenseCategory>)->Void)) {
        
        guard let expenseCategoryBaseUrl = expenseCategoryBaseUrl else {
            return
        }
        
        expenseCategoryBaseUrl.observeEventType(.Value, withBlock: { (dataSnapShot:FDataSnapshot!) -> Void in
            var newCategories = [ExpenseCategory]()
            for dataSnapShot in dataSnapShot.children {
                if let dataSnapShot = dataSnapShot as? FDataSnapshot{
                    let expensItem = ExpenseCategory(snapshot: dataSnapShot)
                    newCategories.append(expensItem)
                }
            }
            handler(newCategories)
        })
    }
    
    func getUser(handler: ( (user: User)-> Void)) {
        
        guard let expenseCategoryBaseUrl = expenseCategoryBaseUrl else {
            return
        }
        
        expenseCategoryBaseUrl.observeAuthEventWithBlock {(authData: FAuthData!) -> Void in
            if authData != nil {
                let user = User.init(authenticatedData: authData)
                handler(user: user)
            }
        }
    }
    
    
    /**
     This is required method observe user authentication.
     
     - parameter handler: Returns a authenticated  user.
     */
    func observeAuth(handler: (user: User) -> Void) {
        applicationRootReference.observeAuthEventWithBlock { (fAuthData) -> Void in
            if fAuthData != nil {
                let user = User(authenticatedData: fAuthData)
                handler(user: user)
            }
            
        }
    }
    
    /**
     This is required method to change user password.
     
     - parameter emailID:    User email ID
     - parameter fromOld:    old Password
     - parameter toNew:      New password
     - parameter completion: completion handler
     */
    func changePasswordForUser(emailID: String , fromOld: String, toNew: String, completion: (error: NSError?)-> Void) {
        applicationRootReference.changePasswordForUser(emailID, fromOld: fromOld, toNew: toNew) { (error) -> Void in
            completion(error: error)
        }
    }
    
    /* This is required method create new user
    
    - parameter userInfoTuple: userInfoTuple contain user info.
    - parameter completion:    completion handler will called, which conatin error if any or user object.
    */
    func createUserForuserInfo(userInfoTuple: (emailID: String,password: String,userName: String), completion: (error: NSError?, user: User?)-> Void) {
        
        applicationRootReference.createUser(userInfoTuple.emailID, password: userInfoTuple.password) { (error: NSError!) -> Void in
            
            if error == nil {
                self.applicationRootReference.authUser(userInfoTuple.emailID, password: userInfoTuple.password, withCompletionBlock: { (error, fAuthData) -> Void in
                    
                    if error == nil {
                        let user = User(authenticatedData: fAuthData)
                        NSUserDefaults.standardUserDefaults().setObject(user.uid, forKey: "uid")
                        FirebaseNetworkManager.sharedInstance.currentUserRef?.childByAppendingPath("userName").setValue(userInfoTuple.userName)
                        NSUserDefaults.setUserNameToNSDefaults(userInfoTuple.userName)
                        NSUserDefaults.setEmailIDToNSDefaults(user.emailID ?? "")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        completion(error: nil, user: user)
                    } else {
                        completion(error: error, user: nil)
                    }
                })
            } else {
                completion(error: error, user: nil)
            }
        }
    }
    
    
    //    func authenticateUserForUserInfo(userInfoTuple: (emailID: String,password: String), completionHandler: ()-> Void) {
    //
    //        self.applicationRootReference.authUser(userInfoTuple.emailID, password: userInfoTuple.password, withCompletionBlock: { (error, fAuthData) -> Void in
    //
    //            if error == nil {
    //                let user = User(authenticatedData: fAuthData)
    //                NSUserDefaults.standardUserDefaults().setObject(user.uid, forKey: "uid")
    //                FirebaseNetworkManager.sharedInstance.currentUserRef?.childByAppendingPath("userName").setValue(userInfoTuple.userName)
    //                NSUserDefaults.setUserNameToNSDefaults(userInfoTuple.userName)
    //                NSUserDefaults.setEmailIDToNSDefaults(user.emailID ?? "")
    //                NSUserDefaults.standardUserDefaults().synchronize()
    //                completion(error: nil, user: user)
    //            } else {
    //                completion(error: error, user: nil)
    //            }
    //        })
    //
    //    }
}

//
//  Extensions.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 27/04/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import Foundation
import UIKit

// MARK:-Custom method

public enum ActionType: Int {
    case None = 0
    case DismissViewController = 1
    case PopUpViewController = 2
}

public extension UIViewController {
    
    /**
     Custom method to hide the keyboard when user tap around the textfields
     */
    func hideKeyboradWhenTappedAround() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyBoard")
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func dismissKeyBoard() {
        view.endEditing(true)
    }
    
    /**
     This method is used get custom activity view.
     
     - returns: return a custom activity view.
     */
    func getActivityIndicatorView() -> UIView {
        let backGroundView =  UIView(frame: view.bounds)
        backGroundView.backgroundColor = UIColor.blackColor()
        backGroundView.alpha = 0.7
        let acivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        acivityIndicator.center = backGroundView.center
        backGroundView.addSubview(acivityIndicator)
        acivityIndicator.startAnimating()
        return backGroundView
    }
    
    func resignFirstResponder(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func handleError(forError error: NSError?) {
        if let error = error {
              presentAlertControllerForTitle("Error", message: error.localizedDescription, actionType: ActionType.None)
        }
    }
    
    
    /**
     This method is used to display alert controller.
     
     - parameter title:      title for a alert controller.
     - parameter message:    The message for alert controller.
     - parameter actionType: The action to be taken after taping on OK action.
     */
    func presentAlertControllerForTitle(title: String, message: String, actionType: ActionType) {
        let alertController = UIAlertController(title: title, message:message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: .Default) { (action: UIAlertAction) -> Void in
            switch actionType {
                
            case .PopUpViewController: self.navigationController?.popViewControllerAnimated(true)
                
            case .DismissViewController: self.dismissViewControllerAnimated(true, completion: nil)
                
            case .None: break
            }
            
        }
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
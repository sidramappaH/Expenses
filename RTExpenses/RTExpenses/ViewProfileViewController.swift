//
//  ViewProfileViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 04/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var errorMessageLabel: UILabel!
    @IBOutlet private weak var emailIDTextField: UITextField!
    @IBOutlet weak var emailIDTextFieldTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var doneButton: UIBarButtonItem?
    var editButton: UIBarButtonItem?
    private var emailID: String?
    var userName = ""
    
    
    //MARK:- View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialUI()
        navigationItem.rightBarButtonItem = getEditBarButtonItem()
        userNameTextField.delegate = self
        hideKeyboradWhenTappedAround()
    }
    
    override func viewWillAppear(animated: Bool) {
        emailID = NSUserDefaults.standardUserDefaults().objectForKey("EmailID") as? String ?? ""
        emailIDTextField.text = emailID
        
    }
    //MARK:- IBAction methods
    @IBAction func didTapChangeEmailIDButton(sender: UIButton) {
        presentChangeCredentialViewController(true)
    }
    
    @IBAction func didTapChangePasswordButton(sender: UIButton) {
        presentChangeCredentialViewController(false)
    }
    
    @IBAction func didTapDeleteMyAccontButton(sender: UIButton) {
        let alertController = UIAlertController(title: "Delete account?", message: "Pressing Yes would delete your account. Proceed to delete?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action: UIAlertAction) -> Void in
            self.doDeleteAccount()
        }
        let noAction =  UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didTapEditButton(sender: UIButton) {
        navigationItem.rightBarButtonItem = doneButton
        userNameTextField.enabled = true
        userNameTextField.becomeFirstResponder()
    }
    
    func didTapDoneButton(sender: UIButton) {
        
        resignFirstResponder(userNameTextField)
        
        guard let currentUserName =  userNameTextField.text where !currentUserName.isEmpty else {
            errorMessageLabel.hidden = false
            errorMessageLabel.text = "*User name must be a non empty string."
            emailIDTextFieldTopConstraint.constant =  25
            return
        }
        
        if userName == currentUserName {
            userNameTextField.enabled = false
            navigationItem.rightBarButtonItem = editButton
            //No channges
            return
        }
        
        navigationItem.rightBarButtonItem = editButton
        FirebaseNetworkManager.sharedInstance.setUserName(forUserName: self.userNameTextField.text ?? "")
        userNameTextField.enabled = false
        NSUserDefaults.setUserNameToNSDefaults(self.userNameTextField.text ?? "")
        
        presentAlertControllerForTitle("", message: "User name changed successfully.", actionType: ActionType.None)
    }
}


//MARK:- UITextFieldDelegate methods
extension ViewProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let textFieldText =  textField.text where textFieldText.isEmpty {
            errorMessageLabel.hidden = false
            errorMessageLabel.text = "User name must be a non empty string."
            emailIDTextFieldTopConstraint.constant = 25
        }
        errorMessageLabel.hidden = true
        emailIDTextFieldTopConstraint.constant =  10
    }
}

//MARK:- private methods
private extension ViewProfileViewController {
    
    func setUpInitialUI() {
        navigationItem.title = "Profile"
        FirebaseNetworkManager.sharedInstance.getUserName({[weak self] (userName: String) -> Void in
            self?.userNameTextField.text = userName
            self?.userName = userName
            })
        userNameTextField.enabled = false
        
        emailIDTextField.enabled = false
        editButton = getEditBarButtonItem()
        doneButton = getDoneBarButtonItem()
    }
    
    /**
     This is a convenience which returns a EditBarButtonItem
     
     - returns: Returns a EditBarButtonItem
     */
    func getEditBarButtonItem() -> UIBarButtonItem {
        
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "didTapEditButton:")
        
        return editBarButtonItem
    }
    
    /**
     This is a convenience which returns a getDoneBarButtonItem
     
     - returns: Returns a getDoneBarButtonItem
     */
    func getDoneBarButtonItem() -> UIBarButtonItem {
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didTapDoneButton:")
        
        return doneBarButtonItem
    }
    
    func handleKeyBoard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
     This is a convenience method to present a ChangeCredentialViewController
     */
    func presentChangeCredentialViewController(isNeedToChangeEmailID: Bool) {
        
        let changeCredentialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChangeCredentialViewController") as? ChangeCredentialViewController
        if let changeCredentialViewController = changeCredentialViewController {
            
            if let emailID =  emailID {
                changeCredentialViewController.emailID = emailID
                changeCredentialViewController.isFromChangeEmailIDPage = isNeedToChangeEmailID
            }
            navigationController?.pushViewController(changeCredentialViewController, animated: true)
        }
        
    }
    
    func doDeleteAccount() {
        
        let alertController = UIAlertController(title: "Enter password to proceed..", message: "", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (action: UIAlertAction) -> Void in
            
            if let alertControllerTextFields = alertController.textFields {
                
                self.postDeleteRequest(forPassword: alertControllerTextFields[0].text ?? "")
            }
        }
        
        let cancelAction =  UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            
        }
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "Enter Password"
            textField.secureTextEntry = true
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func postDeleteRequest(forPassword password: String) {
        
        let emailID = NSUserDefaults.standardUserDefaults().objectForKey("EmailID") as? String ?? ""
        
        if !emailID.isEmpty {
            
            let applicationRootReference = FirebaseNetworkManager.sharedInstance.applicationRootReference
            applicationRootReference.removeUser(emailID, password: password, withCompletionBlock: { (error: NSError!) -> Void in
                
                if error == nil {
                    FirebaseNetworkManager.sharedInstance.currentUserRef?.removeValue()
                    NSUserDefaults.removeUserDefaultsValues()
                    let alertController = UIAlertController(title: "", message: "Your Expense tracker account deleted  successfully.", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.handleError(forError: error)
                }
            })
        }
    }
}

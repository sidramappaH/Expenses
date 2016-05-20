//
//  ChangeCredentialViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 04/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

enum TextFieldTags: Int {
    case CurrentPasswordTextFieldTag = 1
    case newPasswordOrEmaildTextFieldTag = 2
    case commonPasswordTextFieldTag = 3
}

class ChangeCredentialViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak private var currentPasswordTextField: UITextField!
    @IBOutlet weak private var newPasswordOrEmaildTextField: UITextField!
    @IBOutlet weak private var commonPasswordTextField: UITextField!
    @IBOutlet weak private var submitButton: UIButton!
    @IBOutlet weak private var oldPasswordTextFieldDivider: UIView!
    @IBOutlet weak private var currentPassswordTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var currentPasswordErrorMessageLabel: UILabel!
    @IBOutlet weak private var newPasswordOrEmaiIDErrorMessage: UILabel!
    @IBOutlet weak private var commomPasswordErrorMessage: UILabel!
    //MARK:- Properties
    var emailID  = ""
    private var activityView : UIView?
    private  var firebaseRootReference: Firebase?
    var isFromChangeEmailIDPage = false
    
    //MARK:- View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialUI()
    }
    
    // MARK:- IBAction methods
    @IBAction func didTapSubmitButton(sender: UIButton) {
        resignFirstResponder(currentPasswordTextField)
        resignFirstResponder(newPasswordOrEmaildTextField)
        resignFirstResponder(commonPasswordTextField)
        firebaseRootReference = FirebaseNetworkManager.sharedInstance.applicationRootReference
        
        if isFromChangeEmailIDPage {
            doChangeEmailID()
        } else {
            doChangePassword()
        }
    }
}


//MARK:- Private custom methods
private extension ChangeCredentialViewController {
    
    func setUpInitialUI() {
        hideKeyboradWhenTappedAround()
        currentPasswordTextField.delegate = self
        newPasswordOrEmaildTextField.delegate = self
        commonPasswordTextField.delegate = self
        
        if isFromChangeEmailIDPage {
            currentPassswordTopConstraint.constant =  currentPassswordTopConstraint.constant - 59
            navigationItem.title = "Change Email ID"
            submitButton.layer.cornerRadius = 5
            resetPlaceHolderTextForTextFields()
            currentPasswordTextField.secureTextEntry = false
            newPasswordOrEmaildTextField.secureTextEntry = false
            currentPasswordTextField.hidden = true
            oldPasswordTextFieldDivider.hidden = true
        } else {
            oldPasswordTextFieldDivider.hidden = false
            currentPasswordTextField.hidden = false
            navigationItem.title = "Change password"
            submitButton.layer.cornerRadius = 5
            currentPasswordTextField.secureTextEntry = true
            newPasswordOrEmaildTextField.secureTextEntry = true
        }
    }
    
    /**
     This is a convenience method reset text field plcae holder text.
     */
    func resetPlaceHolderTextForTextFields() {
        currentPasswordTextField.placeholder = "Current Email ID"
        newPasswordOrEmaildTextField.placeholder = "New Email ID"
        commonPasswordTextField.placeholder = "Password"
    }
    
    /**
     This is a useful method to check , whether user entered email ID is already exist or not.
     
     - parameter emailID: User entered email ID
     
     - returns: Boolean flag.
     */
    func isExistingEmailID(forEmailID emailID: String)-> Bool {
        let existingEmailID = NSUserDefaults.standardUserDefaults().valueForKey("EmailID") as? String
        if existingEmailID == emailID {
            return true
        }
        return false
    }
    
    /**
     This is a convenience method to process user change email ID request.
     */
    func doChangeEmailID() {
        
        let userEnteredEmailID = newPasswordOrEmaildTextField.text ?? ""
        let password = commonPasswordTextField.text ?? ""
        let isEmailIDValidated = userEnteredEmailID.isValidEmailID()
        let isPasswordValidated = password.isValidPasswordLength()
        let isEmailIDAlreadyExists = isExistingEmailID(forEmailID: userEnteredEmailID)
        
        guard isEmailIDValidated && isPasswordValidated && !isEmailIDAlreadyExists else {
            if !isEmailIDValidated {
                newPasswordOrEmaiIDErrorMessage.text = "Please enter Valid Email ID."
                newPasswordOrEmaiIDErrorMessage.hidden = false
            } else {
                if isEmailIDAlreadyExists {
                    newPasswordOrEmaiIDErrorMessage.text = "The specified email ID is already taken by you."
                    newPasswordOrEmaiIDErrorMessage.hidden = false
                } else {
                    newPasswordOrEmaiIDErrorMessage.text = ""
                    newPasswordOrEmaiIDErrorMessage.hidden = true
                }
            }
            
            if !isPasswordValidated {
                commomPasswordErrorMessage.text = "Password must be 6 - 10 character long."
                commomPasswordErrorMessage.hidden = false
            } else {
                commomPasswordErrorMessage.text = ""
                commomPasswordErrorMessage.hidden = true
            }
            return
        }
        postChangeEmialIDRequest(emailID, validatedNewEmailID: userEnteredEmailID, password: password)
    }
    
    /**
     This is a convenience method to process user change password request.
     */
    func doChangePassword() {
        let currentPassword =  currentPasswordTextField.text ?? ""
        let newPassword =  newPasswordOrEmaildTextField.text ?? ""
        let confirmPassword = commonPasswordTextField.text ?? ""
        
        let isCurrentPasswordValidated = currentPassword.isValidPasswordLength()
        let isValidatedNewPassword = newPassword.isValidPasswordLength()
        let isValidatedConfirmPassword = (newPassword == confirmPassword) ? true : false
        
        guard isCurrentPasswordValidated && isValidatedNewPassword && isValidatedConfirmPassword else {
            
            if !isCurrentPasswordValidated {
                currentPasswordErrorMessageLabel.text = "Current Password must be 6 - 10 character long."
                currentPasswordErrorMessageLabel.hidden = false
            } else {
                currentPasswordErrorMessageLabel.text = ""
                currentPasswordErrorMessageLabel.hidden = true
            }
            
            if !isValidatedNewPassword {
                newPasswordOrEmaiIDErrorMessage.text = "New Password must be 6 - 10 character long."
                newPasswordOrEmaiIDErrorMessage.hidden = false
            } else {
                
                if !isValidatedConfirmPassword {
                    commomPasswordErrorMessage.text = "Password not matched."
                    commomPasswordErrorMessage.hidden = false
                } else {
                    commomPasswordErrorMessage.text = ""
                    commomPasswordErrorMessage.hidden = true
                }
                newPasswordOrEmaiIDErrorMessage.text = ""
                newPasswordOrEmaiIDErrorMessage.hidden = true
            }
            return
        }
        
        activityView = getActivityIndicatorView()
        if let activityView = activityView {
            view.addSubview(activityView)
        }
        navigationItem.setHidesBackButton(true, animated: false)
        commonPasswordTextField.resignFirstResponder()
        
        postChangePasswordRequest(emailID, currentPassword: currentPassword, NewPassword: newPassword)
    }

    
    //    /**
    //     This is convenience method to handle error conditions for input pararmeter textfield.
    //
    //     - parameter textField: TextField for which error condition to be handled.
    //     */
    func handleErrorConditions(forTextField textField: UITextField) {
        
        switch textField.tag {
            
        case TextFieldTags.newPasswordOrEmaildTextFieldTag.rawValue:
            
            let emailID = textField.text  ?? ""
            
            if !emailID.isValidEmailID() {
                newPasswordOrEmaiIDErrorMessage.text = "Please enter Valid Email ID."
                newPasswordOrEmaiIDErrorMessage.hidden = false
            } else {
                if isExistingEmailID(forEmailID: emailID) {
                    newPasswordOrEmaiIDErrorMessage.text = "The specified email ID is already taken by you."
                    newPasswordOrEmaiIDErrorMessage.hidden = false
                } else {
                    newPasswordOrEmaiIDErrorMessage.text = ""
                    newPasswordOrEmaiIDErrorMessage.hidden = true
                }
            }
            
            
        case TextFieldTags.commonPasswordTextFieldTag.rawValue:
            
            let password = textField.text ?? ""
            
            if !password.isValidPasswordLength() {
                commomPasswordErrorMessage.text = "Password must be 6 - 10 character long."
                commomPasswordErrorMessage.hidden = false
            } else {
                commomPasswordErrorMessage.text = ""
                commomPasswordErrorMessage.hidden = true
            }
            
        default: break
        }
    }
    
    //    /**
    //     This is convenience method to handle error conditions for input pararmeter textfield.
    //
    //     - parameter textField: TextField for which error condition to be handled.
    //     */
    func handleError(forTextField textField: UITextField) {
        
        switch textField.tag {
            
        case TextFieldTags.CurrentPasswordTextFieldTag.rawValue :
            
            let password = textField.text ?? ""
            
            if !password.isValidPasswordLength() {
                currentPasswordErrorMessageLabel.text = "Current password must be 6 - 10 character long."
                currentPasswordErrorMessageLabel.hidden = false
            } else {
                currentPasswordErrorMessageLabel.text = ""
                currentPasswordErrorMessageLabel.hidden = true
            }
            
        case TextFieldTags.newPasswordOrEmaildTextFieldTag.rawValue:
            
            let newPassword = textField.text ?? ""
            
            if !newPassword.isValidPasswordLength() {
                newPasswordOrEmaiIDErrorMessage.text = "New password must be 6 - 10 character long."
                newPasswordOrEmaiIDErrorMessage.hidden = false
            } else {
                newPasswordOrEmaiIDErrorMessage.text = ""
                newPasswordOrEmaiIDErrorMessage.hidden = true
            }
            
        case TextFieldTags.commonPasswordTextFieldTag.rawValue:
            let password =  newPasswordOrEmaildTextField.text ?? ""
            let confirmPassword = textField.text ?? ""
            let isValidatedConfirmPassword =  (password == confirmPassword) ? true : false
            
            if password.isValidPasswordLength() {
                
                if !isValidatedConfirmPassword {
                    commomPasswordErrorMessage.text = "Password not matched."
                    commomPasswordErrorMessage.hidden = false
                } else {
                    commomPasswordErrorMessage.text = ""
                    commomPasswordErrorMessage.hidden = true
                }
            }
            
        default: break
        }
    }
    
    /**
     This is required method post user email change ID request to firebase server.
     
     - parameter oldEmailID:          The old email ID
     - parameter validatedNewEmailID: The validated new email ID
     - parameter password:            The user password
     */
    func postChangeEmialIDRequest(oldEmailID: String, validatedNewEmailID: String, password: String) {
        
        activityView = getActivityIndicatorView()
        if let activityView = activityView {
            view.addSubview(activityView)
        }
        navigationItem.setHidesBackButton(true, animated: false)
        
        firebaseRootReference?.changeEmailForUser(oldEmailID, password: password, toNewEmail: validatedNewEmailID, withCompletionBlock: { [weak self](error: NSError!) -> Void in
            if let weakSelf = self {
                weakSelf.activityView?.removeFromSuperview()
                if error == nil {
                    NSUserDefaults.setEmailIDToNSDefaults(validatedNewEmailID)
                    weakSelf.activityView?.removeFromSuperview()
                    weakSelf.navigationItem.setHidesBackButton(false, animated: false)
                    weakSelf.presentAlertControllerForTitle("", message: "Your account email ID has been changed successfully.", actionType: ActionType.PopUpViewController)
                    
                } else {
                    weakSelf.navigationItem.setHidesBackButton(false, animated: false)
                    weakSelf.handleError(forError: error)
                }
            }
            })
    }
    
    
    /**
     This  method is used to post change password request to firebase server.
     
     - parameter oldEmailID:      The old email ID.
     - parameter currentPassword: The validated currentPassword.
     - parameter newPassword:        The new  password.
     */
    
    func postChangePasswordRequest(emailID: String, currentPassword: String, NewPassword: String) {
        
        FirebaseNetworkManager.sharedInstance.changePasswordForUser(emailID, fromOld: currentPassword, toNew: NewPassword, completion: {[weak self] (error) -> Void in
            
            if let weakSelf = self {
                weakSelf.activityView?.removeFromSuperview()
                weakSelf.navigationItem.setHidesBackButton(false, animated: false)
                if error == nil {
                    weakSelf.presentAlertControllerForTitle("", message: "Your account password has been changed successfully.", actionType: ActionType.PopUpViewController)
                } else {
                    weakSelf.handleError(forError: error)
                }
            }
            })
    }
    
}

// MARK: - UITextFieldDelegate methods
extension ChangeCredentialViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        if isFromChangeEmailIDPage {
            handleErrorConditions(forTextField: textField)
        } else {
            handleError(forTextField: textField)
        }
    }
    
}
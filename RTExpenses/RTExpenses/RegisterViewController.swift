//
//  RegisterViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 25/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

enum TextFieldTag: Int {
    case EmailIDTextFieldTag = 1
    case PasswordTextFieldTag = 2
    case confirmPasswordTextFieldTag = 3
    case UserNameTextFieldTag = 4
    case ExpenseNameTag = 5
    case AmountTag = 6
}

class RegisterViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak private var userNameTextField: UITextField!
    @IBOutlet weak private var emailIDTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var confirmPasswordTextField: UITextField!
    @IBOutlet weak private var registerButton: UIButton!
    @IBOutlet weak private var confirmPasswordErrorMessageLabel: UILabel!
    @IBOutlet weak private var scrollView: UIScrollView!
    
    @IBOutlet weak private var userNameErrorMessageLabel: UILabel!
    @IBOutlet weak private var emailIDErrorMessageLabel: UILabel!
    @IBOutlet weak private var passwordErrorMessageLabel: UILabel!
    
    //MARK:- properties
    private var activityView: UIView?
    private var defaultCategoryNames = [String]()
    var user: User?
    
    //MARK:- View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign up"
        userNameTextField.becomeFirstResponder()
        hideKeyboradWhenTappedAround()
        setAllTextFieldsDelegate()
        configureRegisterButton()
        handleKeyBoard()
    }
    
    //MARK:- IBAction methods
    @IBAction func didTapRegisterButton(sender: UIButton) {
        
        resignFirstResponder(userNameTextField)
        resignFirstResponder(emailIDTextField)
        resignFirstResponder(passwordTextField)
        resignFirstResponder(confirmPasswordTextField)
        
        let userName =  userNameTextField.text ?? ""
        let emailID = emailIDTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        let isValidatedUserName = !userName.isEmpty
        let isValidatedemailID = emailID.isValidEmailID()
        let isValidatedPassword = password.isValidPasswordLength()
        let isValidatedConfirmPassword = (password == confirmPassword) ? true : false
        
        guard isValidatedUserName && isValidatedemailID && isValidatedPassword  && isValidatedConfirmPassword else {
            
            if !isValidatedUserName {
                userNameErrorMessageLabel.hidden = false
                userNameErrorMessageLabel.text = "Required."
            } else {
                
                userNameErrorMessageLabel.hidden = true
                userNameErrorMessageLabel.text = ""
            }
            
            if !isValidatedemailID {
                emailIDErrorMessageLabel.hidden = false
                emailIDErrorMessageLabel.text = "Please enter a valid email ID."
            } else {
                emailIDErrorMessageLabel.hidden = true
                emailIDErrorMessageLabel.text = ""
            }
            
            if  !isValidatedPassword {
                passwordErrorMessageLabel.hidden = false
                passwordErrorMessageLabel.text = "Password must be 6 - 10 character long."
            } else {
                passwordErrorMessageLabel.hidden = true
                passwordErrorMessageLabel.text = ""
            }
            if isValidatedPassword {
                if !isValidatedConfirmPassword {
                    confirmPasswordErrorMessageLabel.hidden = false
                    confirmPasswordErrorMessageLabel.text = "Password not matched."
                } else {
                    confirmPasswordErrorMessageLabel.hidden = true
                    confirmPasswordErrorMessageLabel.text = ""
                }
            }
            
            return
        }
        
        self.activityView = self.getActivityIndicatorView()
        if let activityView = self.activityView {
            self.view.addSubview(activityView)
        }
        navigationItem.setHidesBackButton(true, animated: false)
        createNewUserAndAuthenticateUser(forEmailIdText: emailID, validPassword: password)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        scrollView.contentInset.bottom = 0
        
        if let userInfo = sender.userInfo {
            if let keyBoardHeight =  userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                scrollView.contentInset.bottom = keyBoardHeight + 50
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}

//MARK:- UITextFieldDelegate methods
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.contentOffset = CGPointMake(0, -60)
        handleErrorConditions(forTextField: textField)
    }
}

//MARK:- Private custom methods
private extension RegisterViewController {
    
    func setAllTextFieldsDelegate() {
        userNameTextField.delegate = self
        emailIDTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    func showAlertController(forTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func configureRegisterButton() {
        
        registerButton.layer.cornerRadius = registerButton.bounds.height * 0.3
        
    }
    
    func addDefaultCategoryNamesForNewUser() {
        defaultCategoryNames = ["Banking", "School", "Hospital", "Food", "Groceries", "Fuel",  "Electricity"]
        
        if let categoryReference = FirebaseNetworkManager.sharedInstance.expenseCategoryBaseUrl {
            for categoryName in self.defaultCategoryNames {
                categoryReference.childByAppendingPath(categoryName.lowercaseString).setValue("Empty")
            }
        }
    }
    
    func  createNewUserAndAuthenticateUser(forEmailIdText emailIdText: String, validPassword: String) {
        
        let userInfoTuple = (emailIdText, validPassword, self.userNameTextField.text ?? "")
        
        FirebaseNetworkManager.sharedInstance.createUserForuserInfo(userInfoTuple, completion: { (error, user) -> Void in
            
            guard let user = user  else {
                self.activityView?.removeFromSuperview()
                self.presentAlertControllerForTitle("Error", message: error?.localizedDescription ?? "", actionType: ActionType.None)
                return
            }
            self.user = user
            self.addDefaultCategoryNamesForNewUser()
            self.activityView?.removeFromSuperview()
            self.navigationItem.setHidesBackButton(false, animated: false)
            let alertController = UIAlertController(title: "Registered successfully", message: "Congratulations!! You have successfully created an Expense Tracker account.", preferredStyle: .Alert)
            
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(false)
            })
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    
    /**
     This is convenience method to handle error conditions for input pararmeter textfield.
     
     - parameter textField: TextField for which error condition to be handled.
     */
    func handleErrorConditions(forTextField textField: UITextField) {
        
        switch textField.tag {
            
        case TextFieldTag.EmailIDTextFieldTag.rawValue:
            
            if let emailIDText = textField.text {
                if !emailIDText.isValidEmailID() {
                    emailIDErrorMessageLabel.hidden = false
                    emailIDErrorMessageLabel.text = "Please enter a valid email ID."
                } else {
                    emailIDErrorMessageLabel.hidden = true
                    emailIDErrorMessageLabel.text = ""
                }
            }
            
        case TextFieldTag.PasswordTextFieldTag.rawValue:
            
            if let validPassword = textField.text {
                validatePasswordLength(validPassword)
            }
            
        case confirmPasswordTextField.tag:  let password = passwordTextField.text ?? ""
        
        if !password.isEmpty {
            let confiramPassword = confirmPasswordTextField.text ?? ""
            
            let validateConfirmPassword = (password == confiramPassword) ?  true : false
            
            if !validateConfirmPassword {
                confirmPasswordErrorMessageLabel.hidden = false
                confirmPasswordErrorMessageLabel.text = "Password not matched."
            } else {
                confirmPasswordErrorMessageLabel.hidden = true
                confirmPasswordErrorMessageLabel.text = ""
            }
            }
            
        case TextFieldTag.UserNameTextFieldTag.rawValue: if textField.text?.characters.count == 0 {
            userNameErrorMessageLabel.hidden = false
            userNameErrorMessageLabel.text = "Required."
        } else {
            
            userNameErrorMessageLabel.hidden = true
            userNameErrorMessageLabel.text = ""
            }
            
        default: break
        }
        
    }
    
    
    /**
     This is a convenience method to validate password length.
     
     - parameter validPassword: Password to be validated.
     */
    func validatePasswordLength(password: String) {
        if !password.isValidPasswordLength() {
            passwordErrorMessageLabel.hidden = false
            passwordErrorMessageLabel.text = "Password must be 6 - 10 character long."
        } else {
            passwordErrorMessageLabel.hidden = true
            passwordErrorMessageLabel.text = ""
        }
    }
    
    func handleKeyBoard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
}
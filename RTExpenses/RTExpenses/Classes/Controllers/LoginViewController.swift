//
//  LoginViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 24/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var emailIDTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var secureSigninButton: UIButton!
    @IBOutlet private weak var expenseTrackerHeaderLabel: UILabel!
    @IBOutlet private weak var registerNowButton: UIButton!
    @IBOutlet weak var emailIDErrorMessageLabel: UILabel!
    @IBOutlet weak var passwordErrorMessageLabel: UILabel!
    
    //MARK:- Properties
    let rootReference =  Firebase(url: "https://rtexpenses.firebaseio.com/")
    var user : User?
    var activityView: UIView?
    var isComingFromHome = false
    var goToHomeButton: UIBarButtonItem?
    //MARK: - View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        emailIDTextField.delegate = self
        passwordTextField.delegate = self
        hideKeyboradWhenTappedAround()
        setUpInitialUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        resetTextFields()
        addGoToHomeButton()
        observeUserAuthentication()
    }
    
    //MARK: - Action methods
    @IBAction private func didTappedRagisterNowButton(sender: UIButton) {
        let registerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterViewController") as? RegisterViewController
        if let registerViewController = registerViewController {
            self.navigationController?.pushViewController(registerViewController, animated: false)
        }
    }
    
    @IBAction private func didTappedSecureSigninButton(sender: UIButton) {
        
        
        let emailIDText =  emailIDTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        
        let isValidatedEmailID = emailIDText.isValidEmailID()
        let isValidatedPassword = passwordText.isValidPasswordLength()
        
        guard isValidatedEmailID && isValidatedPassword else {
            
            if !isValidatedEmailID {
                emailIDErrorMessageLabel.text = "Please enter valid email ID."
                emailIDErrorMessageLabel.hidden = false
            } else {
                emailIDErrorMessageLabel.text = ""
                emailIDErrorMessageLabel.hidden = true
            }
            
            if !isValidatedPassword {
                passwordErrorMessageLabel.hidden = false
                passwordErrorMessageLabel.text = "Password must be 6 - 10 character long."
                
            } else {
                passwordErrorMessageLabel.text = ""
                passwordErrorMessageLabel.hidden = true
            }
            return
        }
        
        activityView = getActivityIndicatorView()
        if let activityView = activityView {
            goToHomeButton?.enabled = false
            view.addSubview(activityView)
        }
        resignFirstResponder(emailIDTextField)
        resignFirstResponder(passwordTextField)
        
        authenticateUser(emailIDText, password: passwordText)
    }
    
    func didTapGoToHomeButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK:- UITextFieldDelegate Method
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField.tag {
        case TextFieldTag.EmailIDTextFieldTag.rawValue: validateEmailID(textField.text ?? "")
        case TextFieldTag.PasswordTextFieldTag.rawValue: validatePassword(textField.text ?? "")
        default: break
        }
    }
}

// MARK:- Custom Methods
private extension LoginViewController {
    /**
     This is convenience method to set up initial UI
     */
    func setUpInitialUI() {
        navigationItem.title = "Login"
        secureSigninButton.layer.cornerRadius = 6
        expenseTrackerHeaderLabel.textColor = UIColor.appBlueColor()
        registerNowButton.setTitleColor(UIColor.appBlueColor(), forState: .Normal)
    }
    
    func resetTextFields() {
        emailIDTextField.text = ""
        passwordTextField.text = ""
    }
    
    func addGoToHomeButton() {
        goToHomeButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapGoToHomeButton")
        navigationItem.leftBarButtonItem = goToHomeButton
    }
    
    /**
     This is required method observe user authentication.
     */
    func observeUserAuthentication() {
        FirebaseNetworkManager.sharedInstance.observeAuth { [weak self] (user) -> Void in
            self?.user = user
            let expenseBaseViewController = UIStoryboard(name: "ExpensesBase", bundle: nil).instantiateViewControllerWithIdentifier("ExpenseBaseViewController") as? ExpenseBaseViewController
            if let expenseBaseViewController = expenseBaseViewController {
                expenseBaseViewController.user = self?.user
                self?.navigationController?.pushViewController(expenseBaseViewController, animated: false)
            }
        }
    }
    
    /**
     This is a convenience method to authenticate a user
     
     - parameter emailIDText: Email ID to be authenticated.
     - parameter password:    User password
     */
    func  authenticateUser(emailIDText: String, password: String) {
        FirebaseNetworkManager.sharedInstance.applicationRootReference.authUser(emailIDText, password: password, withCompletionBlock: { [weak self] (error, fAuthData) ->  Void in
            
            self?.activityView?.removeFromSuperview()
            self?.goToHomeButton?.enabled = true
            if error == nil {
                self?.user = User(authenticatedData: fAuthData)
                NSUserDefaults.standardUserDefaults().setObject(self?.user?.uid, forKey: "uid")
                NSUserDefaults.setEmailIDToNSDefaults(self?.user?.emailID ?? "")
                NSUserDefaults.standardUserDefaults().synchronize()
                let expenseBaseViewController = UIStoryboard(name: "ExpensesBase", bundle: nil).instantiateViewControllerWithIdentifier("ExpenseBaseViewController") as? ExpenseBaseViewController
                if let expenseBaseViewController = expenseBaseViewController {
                    expenseBaseViewController.user = self?.user
                    self?.navigationController?.pushViewController(expenseBaseViewController, animated: false)
                }
            } else {
                self?.presentAlertControllerForTitle("Error", message: error.localizedDescription, actionType: ActionType.None)
            }
            })
    }
    
    /**
     This is useful method to validate email ID.
     
     - parameter EmailID: EmailID to be validated.
     */
    func validateEmailID(EmailID: String) {
        
        if !EmailID.isValidEmailID() {
            emailIDErrorMessageLabel.hidden = false
            emailIDErrorMessageLabel.text = "Please enter valid email ID."
            
        } else {
            emailIDErrorMessageLabel.hidden = true
            emailIDErrorMessageLabel.text = ""
        }
    }
    
    /**
     This is useful method to validate Password.
     
     - parameter password: Password to be validated.
     */
    func validatePassword(password: String) {
        
        if !password.isValidPasswordLength() {
            passwordErrorMessageLabel.hidden = false
            passwordErrorMessageLabel.text = "Password must be 6 - 10 character long."
        } else {
            passwordErrorMessageLabel.hidden = true
            passwordErrorMessageLabel.text = ""
        }
    }
}
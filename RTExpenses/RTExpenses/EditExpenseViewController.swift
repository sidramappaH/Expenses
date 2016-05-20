//
//  EditExpenseViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 28/04/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class EditExpenseViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var editOrAddExpenseLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var enterDescriptionHeaderLabel: UILabel!
    @IBOutlet weak var nameErrorMessageLabel: UILabel!
    @IBOutlet weak var amountErrorMessageLabel: UILabel!
    @IBOutlet weak var descriptionErrrorMessageLabel: UILabel!
    
    //MARK:- Properties
    var categoryTitle = ""
    var currentExpense: Expense?
    var isNeedToAddNewExpense = false
    private var previousExpenseName = ""
    private var localCurrencySymbol = ""
    
    //MARK:- View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        localCurrencySymbol = getCurrencySymbol()
        setAllTextFieldDelegate()
    }
    
    //MARK:- IBAction methods
    @IBAction func didTapDoneButton(sender: AnyObject) {
        doSaveExpense()
    }
    
    @IBAction func didTapCancelButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dateTextFieldDidBeginEditing(sender: UITextField) {
        let inputView = getInputView()
        sender.inputView = inputView
    }
    
    func didPressDoneButton(sender: UIButton) {
        dateTextField.resignFirstResponder()
    }
    
    func didDatePickerValueChanged(sender: UIDatePicker) {
        setDate(textFieldToSet: dateTextField, datePicker: sender)
    }
}

// MARK:- UITextViewDelegate methods
extension EditExpenseViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if textView.text.isEmpty {
            descriptionErrrorMessageLabel.hidden = false
            descriptionErrrorMessageLabel.text = "Please enter description."
            textView.text = "Enter description"
            textView.textColor = UIColor.lightGrayColor()
            enterDescriptionHeaderLabel.hidden = true
        } else if textView.text.characters.count < 2000 {
            descriptionErrrorMessageLabel.hidden = true
            descriptionErrrorMessageLabel.text = ""
        } else {
            descriptionErrrorMessageLabel.hidden = false
            descriptionErrrorMessageLabel.text = "Descrption can have maximum 2000 charactes."
        }
        
    }
    
    func textViewDidChange(textView: UITextView) {
        enterDescriptionHeaderLabel.hidden = false
    }
    
}

// MARK:- UITextFieldDelegate methods
extension EditExpenseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            return false
        } else if textField.tag == TextFieldTag.AmountTag.rawValue {
            
            let noDigitsRange = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            if let _ = noDigitsRange {
                if string == localCurrencySymbol {
                    return true
                }
                return false
            }
            return true
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == TextFieldTag.AmountTag.rawValue {
            if textField.text?.characters.count == 0 {
                textField.text =  localCurrencySymbol
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        handleErrorConditions(forTextField: textField)
        
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField.tag == 6 {
            textField.text = localCurrencySymbol
            return false
        }
        return true
    }
}

// MARK:- Custom methods
private extension EditExpenseViewController {
    
    /**
     This required method to set up initial UI.
     */
    func setUpInitialTextFieldsValue() {
        previousExpenseName = currentExpense?.expenseName ?? ""
        nameTextField.text = currentExpense?.expenseName
        amountTextField.text = currentExpense?.expenseAmount
        dateTextField.text = currentExpense?.expenseDate
        
        if currentExpense?.expenseBriefDescription != "" {
            descriptionTextView.text = currentExpense?.expenseBriefDescription
            descriptionTextView.textColor = UIColor.blackColor()
        }
    }
    
    /**
     This is a convenience method save expense to firebase server.
     */
    func doSaveExpense() {
        
        let name =  nameTextField.text ?? ""
        let amount = amountTextField.text ?? ""
        let date  = dateTextField.text ?? ""
        var description = descriptionTextView.text ?? ""
        description = (description == "Enter description" ) ? "" : description
        
        let isValidatedName =   name.characters.count <= 15
        let isAmountEmpty = amount == localCurrencySymbol || amount.isEmpty
        let isValidatedDescription = description.characters.count <= 2000
        
        guard isValidatedName && !isAmountEmpty && isValidatedDescription && !name.isEmpty && !description.isEmpty else {
            
            if name.isEmpty {
                nameErrorMessageLabel.text = "Please enter expense name."
                nameErrorMessageLabel.hidden = false
            } else {
                if !isValidatedName {
                    nameErrorMessageLabel.text = "Expense name can have a maximum 15 characters."
                    nameErrorMessageLabel.hidden = false
                } else {
                    nameErrorMessageLabel.text = ""
                    nameErrorMessageLabel.hidden = true
                }
            }
            
            if isAmountEmpty {
                amountErrorMessageLabel.text = "Please enter amount."
                amountErrorMessageLabel.hidden = false
            } else {
                amountErrorMessageLabel.text = ""
                amountErrorMessageLabel.hidden = true
            }
            
            if description.isEmpty {
                descriptionErrrorMessageLabel.text = "Please enter description."
                descriptionErrrorMessageLabel.hidden = false
            } else {
                descriptionErrrorMessageLabel.text = ""
                descriptionErrrorMessageLabel.hidden = true
            }
            if !description.isEmpty {
                if !isValidatedDescription {
                    descriptionErrrorMessageLabel.text = "Descrption can have maximum 2000 charactes."
                    descriptionErrrorMessageLabel.hidden = false
                } else {
                    descriptionErrrorMessageLabel.text = ""
                    descriptionErrrorMessageLabel.hidden = true
                }
            }
            return
        }
        
        let expensDetailsTuple = (expenseName: name,expenseAmount: amount,expenseDate: date,expenseBriefDescription: description)
        
        if isNeedToAddNewExpense {
            addNewExpense(ForExpenseDetailsTuple: expensDetailsTuple, expenseName: name)
        } else {
            editExpense(ForExpenseDetailsTuple: expensDetailsTuple, expenseName: name)
        }
    }
    
    /**
     This is a convenience method edit and save current expense to firebase server.
     
     - parameter expenseDetailsTuple: expense details to be saved.
     - parameter expenseName:         Current expense name.
     */
    func editExpense(ForExpenseDetailsTuple expenseDetailsTuple: (String, String, String, String),expenseName: String) {
        
        let expensItem = ExpenseCategory(expenseDetailsTuple: expenseDetailsTuple)
        let categoryReference = FirebaseNetworkManager.sharedInstance.getCategoryReferenceForTitle(categoryTitle.lowercaseString)
        
        if let currentCategoryReference = categoryReference {
            
            if !previousExpenseName.isEmpty {
                let prevoiusExpenseNameReference = currentCategoryReference.childByAppendingPath(previousExpenseName.lowercaseString)
                prevoiusExpenseNameReference.childByAppendingPath(currentExpense?.currentExpenseUniqueID).removeValue()
            }
            
            let currentExpenseNameReference = currentCategoryReference.childByAppendingPath(expenseName.lowercaseString)
            let currentExpenseReferenceWithAutoID = currentExpenseNameReference.childByAppendingPath(currentExpense?.currentExpenseUniqueID)
            currentExpenseReferenceWithAutoID.setValue(expensItem.expensesDetailsAsDictionary())
        }
        
        let alertController = UIAlertController(title: "", message: "Changes has been updated successfully.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action: UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     This is a convenience method add new expense.
     
     - parameter expenseDetailsTuple: expense details to be saved.
     - parameter expenseName:         Current expense name.
     */
    func addNewExpense(ForExpenseDetailsTuple expensDetailsTuple: (String, String, String, String),expenseName: String) {
        let expense = ExpenseCategory(expenseDetailsTuple: expensDetailsTuple)
        
        let categoryReference = FirebaseNetworkManager.sharedInstance.getCategoryReferenceForTitle(categoryTitle.lowercaseString)
        if let categoryReference = categoryReference {
            
            let expensNameReference = categoryReference.childByAppendingPath("\(expenseName.lowercaseString)")
            let expenseNameReferenceWithAutoId = expensNameReference.childByAutoId()
            expenseNameReferenceWithAutoId.setValue(expense.expensesDetailsAsDictionary())
            showAlertController(forMessage: "Saved successfully", isNeedToClearTextField: true)
        }
    }
    
    /**
     This is convenience method show alert controller
     
     - parameter message:                The message to be display.
     - parameter isNeedToClearTextField: Boolean value indicating whether, text field to be clear or not.
     */
    func showAlertController(forMessage message: String, isNeedToClearTextField: Bool) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: .Default) { (UIAlertAction) -> Void in
            if isNeedToClearTextField {
                self.clearAllTextFields()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func clearAllTextFields() {
        nameTextField.text = ""
        // amountTextField.text = ""
        dateTextField.text = ""
        descriptionTextView.text = ""
    }
    
    func setAllTextFieldDelegate() {
        nameTextField.delegate = self
        amountTextField.delegate = self
        dateTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    /**
     This is a convenience method to set date to textfield.
     
     - parameter textField: The textfield for which date to be set.
     - parameter datePicker: The date picker .
     */
    func setDate(textFieldToSet textField:UITextField, datePicker: UIDatePicker) {
        let dateFormaterStyle = NSDateFormatter()
        dateFormaterStyle.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormaterStyle.timeStyle = NSDateFormatterStyle.NoStyle
        textField.text = dateFormaterStyle.stringFromDate(datePicker.date)
    }
    
    func setDefaultCurrentDateToDateTextField() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        setDate(textFieldToSet: dateTextField, datePicker: datePicker)
    }
    
    /**
     This is a convenience method to get input view, which has a date picker.
     
     - returns: returns  view.
     */
    
    func getInputView() -> UIView {
        
        let inputView = UIView(frame: CGRectMake(5, 0, view.bounds.width - 10, view.bounds.height/3.5))
        let doneButton = UIButton(frame: CGRectMake(-1, 0, view.bounds.width + 1, 25))
        doneButton.backgroundColor = UIColor.whiteColor()
        doneButton.setTitleColor(UIColor.appBlueColor(), forState: .Normal)
        doneButton.setTitleColor(UIColor.appBlueColor(), forState: .Highlighted)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.layer.borderWidth = 0.5
        doneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        doneButton.addTarget(self, action: "didPressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let datePicker = UIDatePicker(frame: CGRectMake(0, 25, inputView.bounds.width - 10, inputView.bounds.height - 30))
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: "didDatePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        inputView.addSubview(datePicker)
        inputView.addSubview(doneButton)
        return inputView
    }
    
    /**
     This is a required method to setup initial UI.
     */
    func setUpInitialUI() {
        hideKeyboradWhenTappedAround()
        descriptionTextView.layer.cornerRadius = 5
        headerView.layer.borderWidth = 0.5
        headerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        descriptionTextView.setContentOffset(CGPointZero, animated: true)
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        descriptionTextView.layer.cornerRadius = 5
        if  isNeedToAddNewExpense {
            setDefaultCurrentDateToDateTextField()
            descriptionTextView.textColor = UIColor.lightGrayColor()
            editOrAddExpenseLabel.text = "Add expense"
        } else {
            editOrAddExpenseLabel.text = "Edit"
            setUpInitialTextFieldsValue()
            if  let date = dateTextField.text where date.isEmpty {
                setDefaultCurrentDateToDateTextField()
            }
        }
    }
    
    /**
     This is a convenience method to get current local currency symbol.
     
     */
    func getCurrencySymbol() -> String {
        let currentLocale = NSLocale.currentLocale()
        let currencySymbol = currentLocale.objectForKey(NSLocaleCurrencySymbol) as? String ?? ""
        return currencySymbol + " "
    }
    
    /**
     This is convenience method to handle error conditions for input pararmeter textfield.
     
     - parameter textField: TextField for which error condition to be handled.
     */
    func handleErrorConditions(forTextField textField: UITextField) {
        
        switch textField.tag {
            
        case TextFieldTag.ExpenseNameTag.rawValue :
            let name = textField.text ?? ""
            if name.isEmpty {
                nameErrorMessageLabel.text = "Please enter expense name."
                nameErrorMessageLabel.hidden = false
            } else {
                if name.characters.count > 15 {
                    nameErrorMessageLabel.text = "Expense name can have a maximum 15 characters."
                    nameErrorMessageLabel.hidden = false
                } else {
                    nameErrorMessageLabel.text = ""
                    nameErrorMessageLabel.hidden = true
                }
            }
            
            
        case TextFieldTag.AmountTag.rawValue:
            let amount = textField.text  ?? ""
            if  amount.isEmpty {
                amountErrorMessageLabel.text = "Please enter amount."
                amountErrorMessageLabel.hidden = false
            }
            else {
                if amount == localCurrencySymbol {
                    amountErrorMessageLabel.text = "Please enter amount"
                    amountErrorMessageLabel.hidden = false
                    textField.text = ""
                } else {
                    amountErrorMessageLabel.text = ""
                    amountErrorMessageLabel.hidden = true
                }
            }
            
        default: break
        }
        
    }
}
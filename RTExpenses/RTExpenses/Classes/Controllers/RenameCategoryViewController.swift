//
//  RenameCategoryViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 27/04/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class RenameCategoryViewController: UIViewController {
    
    // MARK:- IBOutlets
    @IBOutlet weak var currentCategoryNameTextField: UITextField!
    @IBOutlet weak var newCategoryNameTextField: UITextField!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    // MARK:- Properties
    var currentExpenseCategory: ExpenseCategory?
    var categoryReference: Firebase?
    
    //MARK: View controller life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialUI()
    }
    
    // MARK:- @IBAction methods
    @IBAction func didTapRenameButton(sender: AnyObject) {
        renameCategoryName()
    }
    
    @IBAction func didTapCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK:- UITextFieldDelegate methods
extension RenameCategoryViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        errorMessageLabel.hidden = true
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.characters.count == 0 {
            errorMessageLabel.hidden = false
            errorMessageLabel.text = "*Category name must be a non empty string"
        } else {
            errorMessageLabel.hidden = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Custom private methods
private extension RenameCategoryViewController {
    
    func renameCategoryName() {
        if let newCategoryName = newCategoryNameTextField.text where !(newCategoryName.isEmpty) {
            
            errorMessageLabel.hidden = true
            let currentCategoryReference = categoryReference?.childByAppendingPath(currentExpenseCategory?.name?.lowercaseString)
            currentCategoryReference?.removeValue()
            
            let newCategoryReference = categoryReference?.childByAppendingPath(newCategoryName.lowercaseString)
            var totalExpense = [Expense]()
            if let temp = currentExpenseCategory?.expenses {
                totalExpense  = temp
            }
            
            if totalExpense.count == 0 {
                newCategoryReference?.setValue("Empty")
            } else {
                for expense in totalExpense {
                    let expenseReference = newCategoryReference?.childByAppendingPath(expense.expenseName)
                    let autoIDRefernce = expenseReference?.childByAppendingPath(expense.currentExpenseUniqueID)
                    let expenseItem = ExpenseCategory(expenseDetailsTuple: (expensName: expense.expenseName ?? "", expenseAmount: expense.expenseAmount ?? "", expensDate: expense.expenseDate ?? "", expenseBriefDescription: expense.expenseBriefDescription ?? ""))
                    autoIDRefernce?.setValue(expenseItem.expensesDetailsAsDictionary())
                }
            }
            dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            errorMessageLabel.hidden = false
            errorMessageLabel.text = "*Category name must be a non empty string"
        }
    }
    
    func setUpInitialUI() {
        currentCategoryNameTextField.text = currentExpenseCategory?.name?.capitalizedString
        currentCategoryNameTextField.enabled = false
        newCategoryNameTextField.delegate = self
        renameButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        headerView.layer.borderWidth = 0.5
        headerView.layer.borderColor = UIColor.blackColor().CGColor
        hideKeyboradWhenTappedAround()
    }
}
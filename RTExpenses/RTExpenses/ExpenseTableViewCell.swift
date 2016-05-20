//
//  ExpenseTableViewCell.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 29/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

protocol ExpenseTableViewCellDelegate: NSObjectProtocol {
    func didSelectMoreButton(forCell cell: UITableViewCell, buttonTitle: String)
}

class ExpenseTableViewCell: UITableViewCell {
    
    // MARK:- IBOutlets
    @IBOutlet private weak var expenseNameLabel: UILabel!
    @IBOutlet private weak var expenseDateLabel: UILabel!
    @IBOutlet private weak var expenseAmountLabel: UILabel!
    @IBOutlet private weak var cellContainerView: UIView!
    @IBOutlet private weak var expenseBriefDescriptionLabel: UILabel!
    @IBOutlet private weak var showMoreButton: UIButton!
    
    // MARK:- Properties
    var isNeedToShowMoreButton = false
    weak var expenseTableViewCellDelegate: ExpenseTableViewCellDelegate?
    
    // MARK:- @IBAction methods
    @IBAction func didTapShowMoreButton(sender: UIButton) {
        
        if let expenseTableViewCellDelegate = expenseTableViewCellDelegate {
            expenseTableViewCellDelegate.didSelectMoreButton(forCell: self, buttonTitle: showMoreButton.titleForState(.Normal) ?? "")
        }
    }
    
    // MARK:- Custom Methods
    /**
    This is convenience method to configure cell for given expenseDetail object
    
    - parameter expenseDetail: The expenseDetail object
    */
    func configureCell(expenseTableViewCellDelegate: ExpenseTableViewCellDelegate?, expense: Expense, isNeedToExpandCell: Bool) {
        
        self.expenseTableViewCellDelegate = expenseTableViewCellDelegate
        expenseNameLabel.text = expense.expenseName
        expenseDateLabel.text = expense.expenseDate
        
        if let image = UIImage(named: "common_bg") {
            backgroundColor = UIColor(patternImage: image)
        }
        cellContainerView.layer.cornerRadius = 5
        cellContainerView.clipsToBounds = true
        if let expenseAmount = expense.expenseAmount where !expenseAmount.isEmpty {
            expenseAmountLabel.text = expenseAmount
            // getCurrencyFormat(forExpenseAmount: expenseAmount)
        } else {
            expenseAmountLabel.text = ""
        }
        
        if isNeedToExpandCell {
            expenseBriefDescriptionLabel.numberOfLines = 0
            showMoreButton.setTitle("Less", forState: .Normal)
            showMoreButton.hidden = false
            configureExpenseDescriptionLabel(forCurrentExpenseDetails: expense)
        } else {
            let dummyLabel = UILabel()
            dummyLabel.numberOfLines = 0
            dummyLabel.lineBreakMode = .ByWordWrapping
            dummyLabel.font = expenseBriefDescriptionLabel.font
            let descriptionText = expense.expenseBriefDescription ?? ""
            dummyLabel.text = descriptionText
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            let cellSize = dummyLabel.sizeThatFits(CGSizeMake(screenWidth - 53,  17))
       
            if cellSize.height / 17 > 2.5 {
                isNeedToShowMoreButton = true
            } else {
                isNeedToShowMoreButton = false
            }
            if isNeedToShowMoreButton {
                showMoreButton.setTitle("More", forState: .Normal)
                showMoreButton.hidden = false
            } else {
                showMoreButton.hidden = true
            }
            expenseBriefDescriptionLabel.numberOfLines = 2
        }
        configureExpenseDescriptionLabel(forCurrentExpenseDetails: expense)
    }
}


//MARK:- Custom methods
private extension ExpenseTableViewCell {
    
    func configureExpenseDescriptionLabel(forCurrentExpenseDetails currentExpenseDetails: Expense) {
        
        if let expenseBriefDescription = currentExpenseDetails.expenseBriefDescription where !expenseBriefDescription.isEmpty {
            
            expenseBriefDescriptionLabel.text =  expenseBriefDescription
            expenseBriefDescriptionLabel.textAlignment = .Justified
            expenseBriefDescriptionLabel.hidden = false
        } else {
            expenseBriefDescriptionLabel.text = ""
            expenseBriefDescriptionLabel.textAlignment = NSTextAlignment.Justified
            expenseBriefDescriptionLabel.hidden = true
        }
    }
    
    /**
     This is a convenience method to get expense amount in decimal format for given string value
     
     - parameter expenseAmount: The expense amount in string format
     
     - returns: Decimal format for given input string
     */
    func getCurrencyFormat(forExpenseAmount expenseAmount: String) -> String {
        if let expenseAmount = Int(expenseAmount) {
            let expenseAmountAsNumber = NSNumber(integer: expenseAmount)
            let currencyFormatter = NSNumberFormatter()
            currencyFormatter.numberStyle = .CurrencyStyle
            let currentLocale = NSLocale.currentLocale()
            currencyFormatter.locale = currentLocale
            return currencyFormatter.stringFromNumber(expenseAmountAsNumber) ?? ""
        }
        return ""
    }
    
}
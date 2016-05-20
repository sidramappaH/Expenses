//
//  Expense.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 26/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class Expense: NSObject {
    
    //MARK:- Proerties
    var expenseName :String?
    var expenseAmount: String?
    var expenseDate: String?
    var expenseBriefDescription: String?
    var currentExpenseUniqueID: String?
    
    //Mark:- Designated Initiliazers
    init(expenseName: String, expenseAmount: String,expenseDate: String, expenseBriefDescription: String, currentExpenseUniqueID: String = "") {
        self.expenseName = expenseName
        self.expenseAmount = expenseAmount
        self.expenseDate = expenseDate
        self.expenseBriefDescription = expenseBriefDescription
        self.currentExpenseUniqueID = currentExpenseUniqueID
    }
}

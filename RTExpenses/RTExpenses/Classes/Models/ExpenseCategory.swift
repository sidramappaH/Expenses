//
//  ExpenseCategory.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 26/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import Foundation

class ExpenseCategory {
    
    // MARK:- Properties
    var name: String?
    var expenses = [Expense]()
    var expense: Expense?
    var userName = ""
    
    // MARK:- convenience initializers
    convenience init(expenseDetailsTuple: (expensName: String,expenseAmount: String,expensDate: String,expenseBriefDescription: String)) {
        self.init()
        name = ""
        expense = Expense(expenseName: expenseDetailsTuple.expensName, expenseAmount: expenseDetailsTuple.expenseAmount, expenseDate: expenseDetailsTuple.expensDate , expenseBriefDescription: expenseDetailsTuple.expenseBriefDescription)
    }
    
    convenience init(snapshot: FDataSnapshot) {
        self.init()
        var expensName = ""
        var expenseAmount = ""
        var expensDate = ""
        var expenseBriefDescription = ""
        
        for currentExpense  in snapshot.children {
            
            if let outsideCurrentExpense = currentExpense as? FDataSnapshot {
                
                for insideCurrentExpense in outsideCurrentExpense.children {
                    
                    if let insideCurrentExpense = insideCurrentExpense as? FDataSnapshot {
                        
                        for currentExpenseWithAutoID in insideCurrentExpense.children {
                            
                            if let tempCurrentExpenseWithAutoID = currentExpenseWithAutoID as? FDataSnapshot {
                                
                                expensName =  tempCurrentExpenseWithAutoID.value["expensName"] as? String ?? ""
                                expenseAmount = tempCurrentExpenseWithAutoID.value["expenseAmount"] as? String ?? ""
                                expensDate = tempCurrentExpenseWithAutoID.value["expensDate"] as? String ?? ""
                                expenseBriefDescription = tempCurrentExpenseWithAutoID.value["expenseBriefDescription"] as? String ?? ""
                            }
                            
                            if !expensName.isEmpty {
                                expense = Expense(expenseName:expensName, expenseAmount: expenseAmount, expenseDate: expensDate, expenseBriefDescription: expenseBriefDescription, currentExpenseUniqueID: insideCurrentExpense.key)
                                if let expense = expense {
                                    expenses.append(expense)
                                }
                            }
                            expensName = ""
                            expenseAmount = ""
                            expensDate = ""
                            expenseBriefDescription = ""
                        }
                        
                    }
                }
            }
        }
        name = snapshot.key
    }
    
    convenience init(userDataSnapshot: FDataSnapshot) {
        self.init()
        userName = userDataSnapshot.value["userName"] as? String ?? ""
    }
    
    convenience init(expenesCategoryname: String) {
        self.init()
        name = expenesCategoryname
    }
    
    // MARK:- Custom Methods
    /**
    This is a convenience method to convert given object into dictionary
    
    - returns: return the dictionary which converted into dictionary
    */
    func expensesDetailsAsDictionary() -> AnyObject {
        
        return   [
            "expensesDetails" : [ "expensName" : expense?.expenseName ?? "",
                "expenseAmount" : expense?.expenseAmount ?? "",
                "expensDate" : expense?.expenseDate ?? "",
                "expenseBriefDescription" : expense?.expenseBriefDescription ?? ""
            ]
        ]
    }
}

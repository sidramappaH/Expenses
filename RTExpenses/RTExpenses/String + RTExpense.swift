//
//  String + RTExpense.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 03/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//
import UIKit

extension String {
    
    //Validation for email ID
    func isValidEmailID() -> Bool {
        let emailRegularExpression =  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTestPredicte = NSPredicate(format: "SELF MATCHES %@", emailRegularExpression)
        return emailTestPredicte.evaluateWithObject(self)
    }
    
    //Validation for password
    func isValidPassword(testString: String) -> Bool {
        
        let passwordRegularExpression = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,10}$"
        let passwordTestPredicte = NSPredicate(format: "SELF MATCHES %@", passwordRegularExpression)
        print(passwordTestPredicte.evaluateWithObject(passwordRegularExpression))
        return passwordTestPredicte.evaluateWithObject(passwordRegularExpression)
    }
    
    //Validation for password length
    func isValidPasswordLength() -> Bool {
        if self.characters.count >= 6 &&  self.characters.count <= 10 {
            return true
        }
        return false
    }
}


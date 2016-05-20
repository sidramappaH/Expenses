//
//  ExpenseCategoryListCollectionViewCell.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 26/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class ExpenseCategoryListCollectionViewCell: UICollectionViewCell {
    
    weak var baseControllerDelegate: ExpenseCategoryListCollectionViewCellDelegate?
    // MARK:- IBOutlets
    @IBOutlet private weak var expenseCategoryNameLabel: UILabel!
    @IBOutlet private weak var addNewExpenseCategoryButton: UIButton!
    @IBOutlet private weak var addNewExpenseButton: UIButton!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet private weak var addNewCategoryButtonImageView: UIImageView!
    
    // MARK:- Custom Methods
    
    /**
    This is a convenience method to configure cell object based on given parameters.
    
    - parameter expenseName: Name of the expense.
    - parameter isNeedShowAddNewCategoryButton: Boolean value which indicate, whether to display add new category button in cell or not.
    - parameter baseControllerDelegate:  The delegate object.
    */
    func configurecell(expenseName: String, isNeedToShowAddNewCategoryButton :Bool) {
        
        layer.cornerRadius = 5
        expenseCategoryNameLabel.text = expenseName.capitalizedString
        
        if let image = UIImage(named: "common_bg") {
            backgroundColor = UIColor(patternImage: image)
        }
        if isNeedToShowAddNewCategoryButton {
            //Show add new cetgory button
            categoryIconImageView.hidden = true
            addNewExpenseButton.hidden = isNeedToShowAddNewCategoryButton
            addNewExpenseCategoryButton.hidden = !isNeedToShowAddNewCategoryButton
            expenseCategoryNameLabel.hidden = isNeedToShowAddNewCategoryButton
            addNewCategoryButtonImageView.hidden = false
        } else {
            categoryIconImageView.hidden = false
            categoryIconImageView.layer.cornerRadius = 5
            categoryIconImageView.clipsToBounds = true
            
            addNewExpenseButton.hidden = isNeedToShowAddNewCategoryButton
            expenseCategoryNameLabel.hidden = isNeedToShowAddNewCategoryButton
            addNewExpenseCategoryButton.hidden = !isNeedToShowAddNewCategoryButton
            addNewCategoryButtonImageView.hidden = true
        }
    }
    
    // MARK:- @IBAction Methods
    @IBAction func didTapAddNewExpenseCategoryButton(sender: AnyObject) {
        
        if let tempDelegate = self.baseControllerDelegate {
            if  tempDelegate.respondsToSelector("didTapAddNewExpenseCategoryButton") {
                tempDelegate.didTapAddNewExpenseCategoryButton()
            }
        }
    }
    
    @IBAction func didTapAddNewExpenseButton(sender: UIButton) {
        if let tempDelegate = self.baseControllerDelegate {
            if let text = expenseCategoryNameLabel.text {
                tempDelegate.didTapAddNewExpenseButton(forExpenseCategory: text)
            }
        }
    }
}

protocol ExpenseCategoryListCollectionViewCellDelegate: NSObjectProtocol {
    func didTapAddNewExpenseCategoryButton()
    func didTapAddNewExpenseButton(forExpenseCategory categoryTitle: String)
}

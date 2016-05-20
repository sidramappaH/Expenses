//
//  ExpenseBaseViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 26/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

enum CategoryImageName: String {
    case Banking = "Banking"
    case School = "School"
    case Hospital = "Hospital"
    case Food = "Food"
    case Groceries = "Groceries"
    case Fuel = "Fuel"
    case Electricity = "Electricity"
}

class ExpenseBaseViewController: UIViewController {
    
    // MARK:- IBOutlet Propeties
    @IBOutlet weak var expenseBaseCollectionView: UICollectionView!
    @IBOutlet weak var expensesBaseTableView: UITableView!
    @IBOutlet weak var noRecordsBaseView: UIView!
    
    // MARK:-  Propeties
    var rootReferenceToExpnseCategory = Firebase()
    var expenseCategories = [ExpenseCategory]()
    var expenses = [Expense]()
    var user: User?
    var categoryReference : Firebase?
    var currentCategoryName: String?
    var currentIndexOfCollectionViewCell = 0
    var menuView: MenuView?
    var menuBarButtonItem: UIBarButtonItem?
    var collectionViewGestureRecogizer: UITapGestureRecognizer?
    var tableViewGestureRecogizer: UITapGestureRecognizer?
    var backBarButtonItem: UIBarButtonItem?
    var homeBarButtonItem: UIBarButtonItem?
    var activityView: UIView?
    var tableViewCellSize: CGSize?
    var selectedCellIndex: NSIndexPath?
    var IsCellNeedToExpand = false
    var saveAction: UIAlertAction?
    
    // MARK:- View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        dismissMenuView()
        fetchCategoryList()
        getUserName()
    }
    
    func presentHomeController() {
        let loginViewController =  UIStoryboard(name: "RegisterAndLogin", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("BaseNavigationController")
        self.presentViewController(loginViewController, animated: false, completion: nil)
    }
    
    func didTapMenuBarButton(sender: AnyObject) {
        
        let menuView = (NSBundle.mainBundle().loadNibNamed("MenuView", owner: self, options: nil)).first as? MenuView
        if let menuView = menuView {
            menuView.frame = CGRectMake(-1, 64, view.bounds.width * 0.6, view.bounds.height)
            menuView.menuViewDelegate = self
            menuView.layer.borderWidth = 0.5
            menuView.layer.borderColor = UIColor.lightGrayColor().CGColor
            view.addSubview(menuView)
            self.menuView = menuView
            
            UIView.animateView(menuView)
            
            hideMenuView()
            let backButton = UIButton(frame: CGRectMake(0,0,40,30))
            backButton.setBackgroundImage(UIImage(named: "Left Back Arrow"), forState: .Normal)
            backButton.addTarget(self, action: "didTapMenuBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
            backBarButtonItem = UIBarButtonItem()
            backBarButtonItem?.customView = backButton
            if let backBarButtonItem = backBarButtonItem {
                navigationItem.leftBarButtonItem = backBarButtonItem
            }
        }
    }
    
    func hideMenuView() {
        tableViewGestureRecogizer = UITapGestureRecognizer(target: self, action: "dismissMenuView")
        if let tableViewGestureRecogizer = tableViewGestureRecogizer {
            expensesBaseTableView.addGestureRecognizer(tableViewGestureRecogizer)
        }
        collectionViewGestureRecogizer = UITapGestureRecognizer(target: self, action: "dismissMenuView")
        if let collectionViewGestureRecogizer = collectionViewGestureRecogizer {
            expenseBaseCollectionView.addGestureRecognizer(collectionViewGestureRecogizer)
        }
    }
    
    func dismissMenuView() {
        configureNavigationController()
        if let menuView = menuView {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                menuView.frame = CGRectMake(-menuView.frame.size.width, 64, menuView.frame.size.width, menuView.frame.size.height)
                }) { (Bool) -> Void in
                    menuView.removeFromSuperview()
                    if let collectionViewGestureRecogizer = self.collectionViewGestureRecogizer {
                        self.expenseBaseCollectionView.removeGestureRecognizer(collectionViewGestureRecogizer)
                    }
                    if let tabelViewGestureRecogizer = self.tableViewGestureRecogizer {
                        
                        self.expensesBaseTableView.removeGestureRecognizer(tabelViewGestureRecogizer)
                    }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissMenuView()
        configureNavigationController()
    }
    
    func handleLongTapGestureRecognizer(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state != .Ended  {
            return
        }
        
        let locationInView = longPressGestureRecognizer.locationInView(expenseBaseCollectionView)
        let currentIndexPath =  expenseBaseCollectionView.indexPathForItemAtPoint(locationInView)
        let lastIndexPath = NSIndexPath(forRow: expenseCategories.count, inSection: 0)
        
        if currentIndexPath != lastIndexPath {
            if let currentIndexPath = currentIndexPath {
                showAlertControllerWithActionSheet(forIndexPath: currentIndexPath)
            }
        }
    }
    
    func handleLongPressGestureRecognizerForTableView(LongPressGestureRecognizer: UILongPressGestureRecognizer) {
        if LongPressGestureRecognizer.state != .Ended {
            return
        }
        let locationInView = LongPressGestureRecognizer.locationInView(expensesBaseTableView)
        let currentCellIndexPath = expensesBaseTableView.indexPathForRowAtPoint(locationInView)
        showActionSheetForIndexPath(forIndexPath: currentCellIndexPath, categoryIndex: currentIndexOfCollectionViewCell)
    }
    
    func didTapMenuBackButton(backButton: UIButton) {
        dismissMenuView()
        configureNavigationController()
    }
    
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as? UITextField
        if let saveAction = saveAction, let textField = textField {
            saveAction.enabled = textField.text?.characters.count >= 1
        }
    }
}

// MARK:- ExpenseBaseViewController Action Methods
extension ExpenseBaseViewController : ExpenseCategoryListCollectionViewCellDelegate {
    
    func didTapAddNewExpenseCategoryButton() {
        if let categoryReference = categoryReference {
            let alertController =  getAlertControllerForTextField(forTitle: "Add New Category", message: "",firebaseRootRefence: categoryReference, expenseCategoryList: expenseCategories)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func didTapAddNewExpenseButton(forExpenseCategory categoryTitle: String) {
        let addNewItemViewController = UIStoryboard(name: "ExpensesBase", bundle: nil).instantiateViewControllerWithIdentifier("EditExpenseViewController") as? EditExpenseViewController
        if let addNewItemViewController = addNewItemViewController {
            addNewItemViewController.categoryTitle = categoryTitle
            addNewItemViewController.isNeedToAddNewExpense = true
            presentViewController(addNewItemViewController, animated: true, completion: nil)
            
        }
    }
}

// MARK: - UITableViewDataSource
extension ExpenseBaseViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.expenses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExpenseTableViewCell", forIndexPath: indexPath) as? ExpenseTableViewCell
        let backGroundImage = cellBackGroundImage(foIndexPath: indexPath)
        let backgroundImageView = UIImageView(image: backGroundImage)
        
        cell?.backgroundView = backgroundImageView
        if let cell = cell {
            if indexPath == selectedCellIndex {
                cell.configureCell(self, expense: expenses[indexPath.row], IsNeedToExpandCell: true)
            } else {
                cell.configureCell(self, expense: expenses[indexPath.row], IsNeedToExpandCell: false)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let expenseDeleteAlertController = UIAlertController(title: "Delete expense?", message: "Pressing Yes would delete your current expense. Proceed to delete?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                
                if let currentCategoryName = self.currentCategoryName {
                    let currentItmeCategoryReference = self.rootReferenceToExpnseCategory.childByAppendingPath(currentCategoryName)
                    let expenseName = self.expenses[indexPath.row].expenseName ?? ""
                    let currentExpenseRefence = currentItmeCategoryReference.childByAppendingPath(expenseName.lowercaseString.lowercaseString)
                    let currentExpenseRefenceWithAutoId = currentExpenseRefence.childByAppendingPath(self.expenses[indexPath.row].currentExpenseUniqueID)
                    if self.expenses.count == 1 {
                        self.currentIndexOfCollectionViewCell = 0
                    } else {
                        let lastIndexPath = NSIndexPath(forRow: self.expenseCategories.count, inSection: 0)
                        let currentIndexPath = self.expenseBaseCollectionView.indexPathsForSelectedItems()?.first
                        
                        if lastIndexPath == currentIndexPath {
                            if let tempIndex = self.expenseBaseCollectionView.indexPathsForSelectedItems()?.first?.row {
                                self.currentIndexOfCollectionViewCell = tempIndex - 1
                            }
                            
                        } else {
                            if let tempIndex = self.expenseBaseCollectionView.indexPathsForSelectedItems()?.first?.row {
                                self.currentIndexOfCollectionViewCell = tempIndex
                            }
                        }
                    }
                    currentExpenseRefenceWithAutoId.removeValue()
                    if self.expenses.count == 1 {
                        currentItmeCategoryReference.setValue("Empty")
                    }
                }
            })
            let noAction =  UIAlertAction(title: "No", style: .Cancel, handler: nil)
            
            expenseDeleteAlertController.addAction(noAction)
            expenseDeleteAlertController.addAction(yesAction)
            presentViewController(expenseDeleteAlertController, animated: true, completion: nil)
        }
    }
}

// MARK:- UITableViewDelegate Methods
extension ExpenseBaseViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        selectedCell?.backgroundColor = UIColor.whiteColor()
    }
}

// MARK:- UICollectionViewDataSource Methods
extension ExpenseBaseViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expenseCategories.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExpenseCategoryListCollectionViewCell", forIndexPath: indexPath) as? ExpenseCategoryListCollectionViewCell
        cell?.categoryIconImageView.image = UIImage(named: "ExepensePlaceHolder_converted")
        
        if let cell = cell {
            if indexPath.row == currentIndexOfCollectionViewCell {
                cell.backgroundView = UIImageView(image: UIImage(named: "LightBlue"))
            } else {
                if let image = UIImage(named: "cell_middle") {
                    cell.backgroundView = UIImageView(image: image)
                }
            }
            
            let lastIndexPath = NSIndexPath(forRow: expenseCategories.count, inSection: indexPath.section)
            cell.baseControllerDelegate = self
            if expenseCategories.count == 0 {
                cell.configurecell("", isNeedToShowAddNewCategoryButton: true)
            } else if indexPath == lastIndexPath {
                cell.configurecell("", isNeedToShowAddNewCategoryButton: true)
            } else {
                let expenseCategory = expenseCategories[indexPath.row]
                let defaultCategoryImage = categoryImage(forCategoryName: expenseCategory.name ?? "")
                cell.categoryIconImageView.image = defaultCategoryImage
                cell.categoryIconImageView.contentMode = .ScaleAspectFit
                cell.configurecell(expenseCategory.name ?? "", isNeedToShowAddNewCategoryButton: false)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.width/2 - 25, expenseBaseCollectionView.bounds.height - 20)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
}

// MARK:- UICollectionViewDelegate Methods
extension ExpenseBaseViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let previousSelectedCellIndexPath = NSIndexPath(forRow: currentIndexOfCollectionViewCell, inSection: indexPath.section)
        let previousSelectedCell = collectionView.cellForItemAtIndexPath(previousSelectedCellIndexPath)
        
        if let previousSelectedCell = previousSelectedCell {
            let cellBackgroundImage = cellBackGroundImage(foIndexPath: previousSelectedCellIndexPath)
            previousSelectedCell.backgroundView = UIImageView(image: cellBackgroundImage)
        }
        
        let lastIndexPath = NSIndexPath(forRow: expenseCategories.count, inSection: indexPath.section)
        if indexPath != lastIndexPath {
            currentIndexOfCollectionViewCell = indexPath.row
        }
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as? ExpenseCategoryListCollectionViewCell
        
        if let currentCell = currentCell {
            if indexPath.row == currentIndexOfCollectionViewCell {
                currentCell.backgroundView = UIImageView(image: UIImage(named: "LightBlue"))
            } else {
                let cellBackgroundImage = cellBackGroundImage(foIndexPath: indexPath)
                currentCell.backgroundView = UIImageView(image: cellBackgroundImage)
            }
        }
        
        if  currentIndexOfCollectionViewCell <= expenseCategories.count - 1 {
            let currentCategory = self.expenseCategories[currentIndexOfCollectionViewCell]
            self.expenses = currentCategory.expenses
            if self.expenses.count == 0 {
                expensesBaseTableView.hidden = true
                noRecordsBaseView.hidden = false
            } else {
                expensesBaseTableView.hidden = false
                noRecordsBaseView.hidden = true
                currentCategoryName =  currentCategory.name
                resetTableViewParameters()
                expensesBaseTableView.reloadData()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let tempCell = collectionView.cellForItemAtIndexPath(indexPath) {
            let currentCell = tempCell as? ExpenseCategoryListCollectionViewCell
            if let currentCell = currentCell {
                let cellBackgroundImage = cellBackGroundImage(foIndexPath: indexPath)
                currentCell.backgroundView = UIImageView(image: cellBackgroundImage)
            }
        }
    }
}

// MARK:- MenuViewDelegate Methods
extension ExpenseBaseViewController: MenuViewDelegate {
    
    func didSelectMenuView(menuView: MenuView, indexPath: NSIndexPath, name: String) {
        
        switch name {
            
        case "Home": self.navigationController?.dismissViewControllerAnimated(true, completion: {});
        case "Add new category":    if let categoryReference = categoryReference {
            let alertController = getAlertControllerForTextField(forTitle: "Add New Category", message: "",firebaseRootRefence: categoryReference, expenseCategoryList: expenseCategories)
            presentViewController(alertController, animated: true, completion: nil)
            }
            
        case "View profile": let viewProfileController = UIStoryboard(name: "Profile", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ViewProfileViewController") as? ViewProfileViewController
        
        if let viewProfileController = viewProfileController {
            dismissMenuView()
            navigationController?.pushViewController(viewProfileController, animated: true)
            }
            
        case "Settings": print("Settings case")
            
        case "Logout": didTapSignOutButton()
            
        default : return
            
        }
    }
}

extension ExpenseBaseViewController: ExpenseTableViewCellDelegate {
    
    func didSelectMoreButton(forCell cell: UITableViewCell, buttonTitle: String) {
        
        if  buttonTitle == "Less" {
            resetTableViewParameters()
            expensesBaseTableView.reloadData()
        } else {
            if IsCellNeedToExpand {
                resetTableViewParameters()
            }
            IsCellNeedToExpand = true
            selectedCellIndex = expensesBaseTableView.indexPathForCell(cell)
            expensesBaseTableView.reloadData()
        }
    }
}

// MARK:- Custom Methods
private extension ExpenseBaseViewController {
    /**
     This is a convenience method to configure a navigation controller
     */
    func configureNavigationController() {
        navigationItem.setHidesBackButton(true, animated: true)
        let localHomeBarButtonItem  =  getMenuBarButtonItem()
        homeBarButtonItem = localHomeBarButtonItem
        navigationItem.leftBarButtonItem = localHomeBarButtonItem
    }
    
    /**
     
     This is a convenience method to get proper image based on cell indexpath.
     - parameter indexPath: cell index path.
     
     - returns: return a image based on indexPath.
     */
    func cellBackGroundImage(foIndexPath indexPath: NSIndexPath) -> UIImage? {
        
        let cellLastIndexPath = NSIndexPath(forItem: expenses.count - 1, inSection: 0)
        
        switch indexPath.row {
            
        case 0 : return UIImage(named: "cell_top")
            
        case cellLastIndexPath.row : return UIImage(named: "cell_middle")
            
        default : return UIImage(named: "cell_middle")
        }
    }
    
    /**
     This is a convenience method to configure initial UI.
     */
    func setUpInitialUI() {
        
        activityView = getActivityIndicatorView()
        if let activityView = activityView {
            view.addSubview(activityView)
        }
        expenseBaseCollectionView.hidden = true
        
        
        if let user = user, let userID = user.uid {
            categoryReference = Firebase(url: "https://rtexpenses.firebaseio.com/" + userID + "/expens-items")
        }
        
        expensesBaseTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        expensesBaseTableView.estimatedRowHeight = 106
        expensesBaseTableView.rowHeight = UITableViewAutomaticDimension
        
        if let patternImage = UIImage(named: "common_bg") {
            noRecordsBaseView.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        
        if let image = UIImage(named: "common_bg") {
            expenseBaseCollectionView.backgroundColor = UIColor(patternImage: image)
        }
        
        configureNavigationController()
        if let user = user, let userID = user.uid {
            rootReferenceToExpnseCategory = Firebase(url: "https://rtexpenses.firebaseio.com/" + userID + "/expens-items")
        }
        expenseBaseCollectionView.registerNib(UINib(nibName: "ExpenseCategoryListCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "ExpenseCategoryListCollectionViewCell")
        
        addLongPressGestureRecognizerForCollectionView()
        addLongPressGestureRecognizerForTableView()
    }
    
    /**
     This is a convenience method which is called when user tapped on logout button.
     */
    func didTapSignOutButton() {
        FirebaseNetworkManager.sharedInstance.applicationRootReference.unauth()
        NSUserDefaults.removeUserDefaultsValues()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     This is a convenience method which adds a long press gesture recognizer to CollectionView
     */
    func addLongPressGestureRecognizerForCollectionView() {
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongTapGestureRecognizer:")
        expenseBaseCollectionView.addGestureRecognizer(longTapGestureRecognizer)
    }
    
    /**
     This is a convenience method which adds a long press gesture recognizer to TableView
     */
    func addLongPressGestureRecognizerForTableView() {
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGestureRecognizerForTableView:")
        expensesBaseTableView.addGestureRecognizer(longTapGestureRecognizer)
    }
    
    
    /**
     This method is used to dispaly action sheet to rename  the expense for given cell indexpath
     
     - parameter indexPath: cell index path
     */
    func showAlertControllerWithActionSheet(forIndexPath indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: "Choose option", message: "", preferredStyle: .ActionSheet)
        let RenameAction = UIAlertAction(title: "Rename", style: .Default) { (action: UIAlertAction) -> Void in
            let renameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RenameCategoryViewController") as? RenameCategoryViewController
            if let renameViewController = renameViewController {
                renameViewController.currentExpenseCategory = self.expenseCategories[indexPath.row]
                renameViewController.categoryReference = self.rootReferenceToExpnseCategory
                self.presentViewController(renameViewController, animated: true, completion:nil)
            }
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (action: UIAlertAction) -> Void in
            
            let categoryDeleteAlertController = UIAlertController(title: "Delete category?", message: "Pressing Yes would delete your current category. Proceed to delete?", preferredStyle: .Alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action: UIAlertAction) -> Void in
                let currentCategoryName = self.expenseCategories[indexPath.row].name
                let currentItmeCategoryReference = self.rootReferenceToExpnseCategory.childByAppendingPath(currentCategoryName)
                currentItmeCategoryReference.removeValue()
            }
            let noActon  = UIAlertAction(title: "No", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
                self.showAlertControllerWithActionSheet(forIndexPath: indexPath)
            })
            
            categoryDeleteAlertController.addAction(noActon)
            categoryDeleteAlertController.addAction(yesAction)
            self.presentViewController(categoryDeleteAlertController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction ) -> Void in
            
        }
        alertController.addAction(RenameAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        alertController.modalTransitionStyle =  UIModalTransitionStyle.FlipHorizontal
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     This method is used to dispaly action sheet to rename  the category for given collectionview cell indexpath.
     
     - parameter indexPath: Collectionview cell indexpath.
     - parameter categoryIndex: Category index.
     */
    func showActionSheetForIndexPath(forIndexPath indexPath: NSIndexPath?, categoryIndex: Int) {
        let alertController = UIAlertController(title: "Choose option", message: "", preferredStyle: .ActionSheet)
        let renameAction = UIAlertAction(title: "Edit", style: .Default) { (action: UIAlertAction) -> Void in
            
            self.editExpenseName(forIndexPath: indexPath)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (action: UIAlertAction) -> Void in
            self.handleExpenseNameDeletion(indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            
        }
        alertController.addAction(renameAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     This is a convenience method used to delete a expense for a given tableview cell indexpath.
     
     - parameter indexPath:  Tableview cell indexpath.
     */
    func handleExpenseNameDeletion(indexPath: NSIndexPath?) {
        let currentCategory = self.expenseCategories[self.currentIndexOfCollectionViewCell]
        let currentCategoryName = currentCategory.name
        let currentCategoryReference = self.rootReferenceToExpnseCategory.childByAppendingPath(currentCategoryName?.lowercaseString)
        
        if let rowIndex = indexPath?.row {
            let currentExpenseName = self.expenses[rowIndex]
            let expenseName = currentExpenseName.expenseName
            let currentExpenseUniqueID = currentExpenseName.currentExpenseUniqueID
            let currentExpenseReference = currentCategoryReference.childByAppendingPath(expenseName?.lowercaseString)
            //currentExpenseReference.removeValue()
            let currentExpenseReferenceWithAutoID = currentExpenseReference.childByAppendingPath(currentExpenseUniqueID)
            currentExpenseReferenceWithAutoID.removeValue()
        }
        
        if currentCategory.expenses.count == 1 {
            let currentCategoryReference = self.rootReferenceToExpnseCategory.childByAppendingPath(currentCategoryName?.lowercaseString)
            currentCategoryReference.setValue("Empty")
        }
    }
    
    /**
     This is a convenience method used to edit a expense for a given tableview cell indexpath.
     
     - parameter indexPath:  Tableview cell indexpath.
     */
    func editExpenseName(forIndexPath indexPath: NSIndexPath?) {
        let currentCategory = self.expenseCategories[self.currentIndexOfCollectionViewCell]
        let currentCategoryName = currentCategory.name
        if let rowIndex = indexPath?.row {
            let currentExpenseName = self.expenses[rowIndex]
            let updateExpenseViewcontrolller = self.storyboard?.instantiateViewControllerWithIdentifier("EditExpenseViewController") as? EditExpenseViewController
            
            if let updateExpenseViewcontrolller = updateExpenseViewcontrolller {
                updateExpenseViewcontrolller.categoryTitle = currentCategoryName?.lowercaseString ?? ""
                updateExpenseViewcontrolller.currentExpense = currentExpenseName
                updateExpenseViewcontrolller.isNeedToAddNewExpense = false
                presentViewController(updateExpenseViewcontrolller, animated: true, completion: nil)
            }
        }
    }
    
    
    /**
     This is a convenience which returns a UIBarButtonItem.
     
     - returns: Returns a UIBarButtonItem
     */
    func getMenuBarButtonItem() -> UIBarButtonItem {
        let menuButton = UIButton(frame: CGRectMake(0,0,40,30))
        menuButton.setBackgroundImage(UIImage(named: "menuImage"), forState: .Normal)
        menuButton.addTarget(self, action: "didTapMenuBarButton:", forControlEvents: UIControlEvents.TouchUpInside)
        let navigationBarButtonItem = UIBarButtonItem()
        navigationBarButtonItem.customView = menuButton
        return navigationBarButtonItem
    }
    
    
    /**
     This is a convenience method used to get alert controller with text field, which allow user to enter a category name.
     
     - parameter title:               The title of alert controller.
     - parameter message:             The message of a alert controller.
     - parameter firebaseRootRefence: The firebase category reference, where new added category is going to be saved.
     - parameter expenseCategoryList: expenseCategoryList is a existing category list.
     
     - returns: Retruns configured alert controller.
     */
    func getAlertControllerForTextField(forTitle title: String, message: String, firebaseRootRefence: Firebase, expenseCategoryList: [ExpenseCategory]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            if let textFields = alertController.textFields {
                self.removeTextFieldObserver(forTextField: textFields[0])
            }
        }
        
        let saveAction = self.getSaveAction(title, message: message, firebaseRootRefence: firebaseRootRefence, expenseCategoryList: expenseCategoryList, alertController: alertController)
        
        saveAction.enabled = false
        self.saveAction = saveAction
        alertController.addTextFieldWithConfigurationHandler { (categoryNameTextField: UITextField) -> Void in
            categoryNameTextField.placeholder = "Enter category name"
            self.addObserver(forTextField: categoryNameTextField)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        return alertController
    }
    
    /**
     This is a convenience method to get category image based on category name.
     
     - parameter categoryName: Name of a category.
     
     - returns: Returns a image.
     */
    func categoryImage(forCategoryName categoryName: String) -> UIImage? {
        
        switch categoryName.capitalizedString {
        case CategoryImageName.Banking.rawValue: return UIImage(named: "Banking")
        case CategoryImageName.School.rawValue: return UIImage(named: "School")
        case CategoryImageName.Hospital.rawValue: return UIImage(named: "Hospital")
        case CategoryImageName.Food.rawValue: return UIImage(named: "Food")
        case CategoryImageName.Groceries.rawValue: return UIImage(named: "Groceries")
        case CategoryImageName.Fuel.rawValue: return UIImage(named: "Fuel")
        case CategoryImageName.Electricity.rawValue: return UIImage(named: "Electricity")
        default: return UIImage(named: "ExepensePlaceHolder_converted")
            
        }
    }
    
    func resetTableViewParameters() {
        selectedCellIndex =  nil
        IsCellNeedToExpand = false
    }
    
    func addObserver(forTextField textField: UITextField) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    func removeTextFieldObserver(forTextField textField: UITextField?) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    /**
     This is required method to fetch category list.
     */
    func  fetchCategoryList() {
        
        FirebaseNetworkManager.sharedInstance.getCategoryList { [weak self](newCategories) -> Void in
            self?.expenseCategories = newCategories
            self?.expenses.removeAll()
            if let expenseCategories = self?.expenseCategories {
                for (index,element) in expenseCategories.enumerate() {
                    if index == self?.currentIndexOfCollectionViewCell {
                        let startingCategory = element
                        self?.currentCategoryName = startingCategory.name
                        self?.expenses = startingCategory.expenses
                        break
                    }
                }
            }
            if self?.expenses.count == 0 {
                self?.expensesBaseTableView.hidden = true
                self?.noRecordsBaseView.hidden = false
            } else {
                self?.expensesBaseTableView.hidden = false
                self?.noRecordsBaseView.hidden = true
            }
            self?.activityView?.removeFromSuperview()
            self?.expenseBaseCollectionView.hidden = false
            if let patternImage = UIImage(named: "common_bg") {
                self?.expensesBaseTableView.backgroundColor = UIColor(patternImage:  patternImage)
            }
            self?.expenseBaseCollectionView.reloadData()
            self?.expensesBaseTableView.reloadData()
        }
        
    }
    
    /**
     This is helpfull method to get user name.
     */
    func getUserName() {
        FirebaseNetworkManager.sharedInstance.getUser { (user: User) -> Void in
            self.user = user
        }
    }
    
    /**
     This is useful method to get customized save action for alert controller.
     
     - parameter title:               Title of a alert controller
     - parameter message:
     - parameter title:               Message of alert contoller
     - parameter firebaseRootRefence: firebaseRootRefence to category list
     - parameter expenseCategoryList: Currently existing expenseCategoryList
     - parameter alertController:     alert contoller
     
     - returns: return a customized save action
     */
    func getSaveAction(title: String, message: String, firebaseRootRefence: Firebase, expenseCategoryList: [ExpenseCategory], alertController: UIAlertController) -> UIAlertAction {
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction) -> Void in
            
            var textFields = [UITextField]()
            if let textFieldArray = alertController.textFields {
                textFields = textFieldArray
                self.removeTextFieldObserver(forTextField: textFields[0])
            }
            
            let categoryNameTextField = textFields[0]
            if let categoryNameInTextField = categoryNameTextField.text where !categoryNameInTextField.isEmpty {
                
                var isExistsCategoryAlready = false
                
                for expense in expenseCategoryList {
                    let categoryName = expense.name ?? ""
                    if categoryName.lowercaseString == categoryNameInTextField.lowercaseString {
                        let alertController = UIAlertController(title: "", message: "Category already exists.", preferredStyle: .Alert)
                        let alertAction = UIAlertAction(title: "Ok", style: .Default) { (tempAction) -> Void in
                            let categoryEnteryAlertcontroller =  self.getAlertControllerForTextField(forTitle: title, message: message, firebaseRootRefence: firebaseRootRefence, expenseCategoryList: expenseCategoryList)
                            self.presentViewController(categoryEnteryAlertcontroller, animated: true, completion: nil)
                        }
                        alertController.addAction(alertAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        isExistsCategoryAlready = true
                        break
                    } else {
                        isExistsCategoryAlready = false
                    }
                }
                
                if !isExistsCategoryAlready {
                    let categoryReference =  firebaseRootRefence.childByAppendingPath(categoryNameInTextField.lowercaseString)
                    
                    let categoryPriority = NSNumber(integer: 1)
                    categoryReference.setValue("Empty", andPriority: categoryPriority)
                    
                    let alertController = UIAlertController(title: "", message: "Saved successfully.", preferredStyle: .Alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .Default) { (tempAction) -> Void in
                        self.dismissMenuView()
                    }
                    alertController.addAction(alertAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "Error", message: "Category name should be a non empty string. Please enter a category name", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "Ok", style: .Default) { (tempAction) -> Void in
                    let categoryEnteryAlertcontroller =  self.getAlertControllerForTextField(forTitle: title, message: message, firebaseRootRefence: firebaseRootRefence, expenseCategoryList: expenseCategoryList)
                    self.presentViewController(categoryEnteryAlertcontroller, animated: true, completion: nil)
                }
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        return saveAction
    }
}

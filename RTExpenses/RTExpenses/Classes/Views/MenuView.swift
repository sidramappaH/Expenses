//
//  MenuView.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 09/04/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

protocol MenuViewDelegate: NSObjectProtocol {
    
    func didSelectMenuView(menuView: MenuView, indexPath: NSIndexPath, name: String)
    
}

class MenuView: UIView {
    
    @IBOutlet weak var menuTableView: UITableView!
    weak var menuViewDelegate: MenuViewDelegate?
    
    let menuNames = ["Home", "Add new category","View profile", "Settings", "Logout"]
    let menuIcons = ["home-icon", "Add new category", "Edit Profile", "Settings", "Logout"]
    
    override func awakeFromNib() {
        menuTableView.estimatedRowHeight = 100
        menuTableView.rowHeight = UITableViewAutomaticDimension
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.registerNib(UINib(nibName: "MenuTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuTableViewCell")
    }
}

extension MenuView: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCell", forIndexPath: indexPath) as? MenuTableViewCell
        
        if let cell = cell {
            cell.configureCell(forName: menuNames[indexPath.row], iconName: menuIcons[indexPath.row])
            setCellSelectedBackgroundView(forCell: cell)
            
            return cell
        }
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}

extension MenuView: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let menuViewDelegate = menuViewDelegate {
            menuViewDelegate.didSelectMenuView(self, indexPath: indexPath, name: menuNames[indexPath.row])
        }
    }
}

private extension MenuView {
    
    func setCellSelectedBackgroundView(forCell cell: MenuTableViewCell) {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.appBlueColor()
        cell.selectedBackgroundView = selectedBackgroundView
    }
}
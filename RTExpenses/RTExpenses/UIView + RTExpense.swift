//
//  UIView + RTExpense.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 16/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     This is convenience method to animate view from left to right.
     
     - parameter view: The view to be animated
     */
    class func animateView(view: UIView) {
        
        var frame = view.frame
        frame.origin.x = -view.frame.size.width
        view.frame = frame
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            frame.origin.x = 0
            view.frame = frame
            }, completion: nil)
    }
}

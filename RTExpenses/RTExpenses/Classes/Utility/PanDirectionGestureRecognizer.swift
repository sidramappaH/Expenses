//
//  PanDirectionGestureRecognizer.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 24/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum PanDirection {
    case Vertical
    case Horizontal
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    // MARK:- Properties
    let direction : PanDirection
    var moveX = 0
    var moveY = 0
    
    // MARK:- Desiganated initiliazers
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    // MARK:- NSResponder Class Methods
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if self.state == UIGestureRecognizerState.Cancelled {
            return
        }
        if state == .Began {
            let velocity = velocityInView(self.view!)
            switch direction {
            case .Horizontal where fabs(velocity.y) > fabs(velocity.x):
                state = .Cancelled
            case .Vertical where fabs(velocity.x) > fabs(velocity.y):
                state = .Cancelled
            default:
                break
            }
        }
    }
}

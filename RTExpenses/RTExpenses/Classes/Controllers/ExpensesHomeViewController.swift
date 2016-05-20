//
//  ExpensesHomeViewController.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 23/03/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class ExpensesHomeViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var digitalTimerLabel: UILabel!
    @IBOutlet private weak var dayAndDateLabel: UILabel!
    @IBOutlet private weak var welcomeMessageLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var swipeUpToUnlockLabel: UILabel!
    
    //MARK:- Maximum & minimum Size Constants for Labels
    private let minmumSizeLabel: CGFloat = 0
    private var maximumSizeOfDigitalTimerLabel: CGFloat = 0
    private var maximumSizeOfDayAndDateLabel: CGFloat = 0
    private var maximumSizeOfWelcomeMessageLabel: CGFloat = 0
    private var loginViewControlFlag = false
    private var isLoginPageNeedToDisplay = true
    private var currentUser: User?
    private var weekDayNames = [Int :  String]();
    
    //MARK:- View Controller Life Cycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpWeekDayNameDictionary()
        setMaximumSizeOfLabels()
        setCurrentDate()
        setUpTimer()
        addPanGestureRecognizer()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        setWelcomeMessageLabel()
        resetSizesOfLabels()
        swipeUpToUnlockLabel.hidden = false
        isLoginPageNeedToDisplay = true
    }
    
    //MARK: - Custom Methods
    /**
    This is a actin method which handle pan gesture recognization.
    */
    func handlePanGestureRecognizer(panGestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = panGestureRecognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) {
            adjustFontSizeOfLabel(forLabel: digitalTimerLabel, translation: translation.y * 0.08, maximumSizeOfLabel: maximumSizeOfDigitalTimerLabel)
            adjustFontSizeOfLabel(forLabel: dayAndDateLabel, translation: translation.y * 0.05, maximumSizeOfLabel: maximumSizeOfDayAndDateLabel)
            adjustFontSizeOfLabel(forLabel: welcomeMessageLabel, translation: translation.y * 0.1, maximumSizeOfLabel: maximumSizeOfWelcomeMessageLabel)
        }
        
        if panGestureRecognizer.state == .Began {
            swipeUpToUnlockLabel.hidden = true
        }
        
        if welcomeMessageLabel.font.pointSize <= 5 {
            loginViewControlFlag = true
            if loginViewControlFlag  && isLoginPageNeedToDisplay {
                let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as? UINavigationController
                if let navigationController = navigationController {
                    let viewControllers = navigationController.viewControllers
                    let loginViewController = viewControllers.first as? LoginViewController
                    loginViewController?.isComingFromHome = true
                    presentViewController(navigationController, animated: true, completion: nil)
                }
                isLoginPageNeedToDisplay = false
            }
        } else {
            if panGestureRecognizer.state == .Ended {
                swipeUpToUnlockLabel.hidden = false
                resetSizesOfLabels()
            }
            loginViewControlFlag = false
        }
    }
    
    /**
     This is a convenience method to get current system date and set to label.
     */
     //MARK: - Custom Methods
    func setCurrentDate() {
        
        let date = NSDate()
        let calender = NSCalendar.currentCalendar()
        let hourComponents = calender.components(NSCalendarUnit.Hour, fromDate: date)
        let minuteComponents = calender.components( NSCalendarUnit.Minute, fromDate: date)
        let hour = hourComponents.hour
        var minute = String(minuteComponents.minute)
        
        if minuteComponents.minute < 10 {
            minute = "0" + String(minute)
        }
        
        if hour < 12 {
            let hourInTwelveHourFormat = getHourAs12HourFormat(forhour: hour)
            let formattedTime = String(hourInTwelveHourFormat) + " : " + String(minute)
            digitalTimerLabel.text = formattedTime + " AM"
        } else {
            let hourIntwelveHourFormat = getHourAs12HourFormat(forhour: hour)
            let formattedTime = String(hourIntwelveHourFormat) + " : " + String(minute)
            digitalTimerLabel.text = formattedTime + " PM"
        }
        
        setFormattedDate(formCalender: calender, date: date)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !loginViewControlFlag  {
            swipeUpToUnlockLabel.hidden = false
        }
    }
}

// MARK:- Private custom methods
private extension ExpensesHomeViewController {
    
    /**
     This is a convenience method store maximum defaults size of a label.
     */
    func setMaximumSizeOfLabels() {
        maximumSizeOfDigitalTimerLabel = digitalTimerLabel.font.pointSize
        maximumSizeOfDayAndDateLabel = dayAndDateLabel.font.pointSize
        maximumSizeOfWelcomeMessageLabel = welcomeMessageLabel.font.pointSize
    }
    
    /**
     This is a convenience method to set up a timer
     */
    func setUpTimer() {
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "setCurrentDate", userInfo: nil, repeats: true)
    }
    
    /**
     This is a convenience method to add pan getsure recognizer in view.
     */
    func addPanGestureRecognizer() {
        
        let panGestureRecognizer = PanDirectionGestureRecognizer(direction: PanDirection.Vertical, target: self, action: "handlePanGestureRecognizer:")
        view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    /**
     This is a convenience method to reset label size to original size.
     */
    func resetSizesOfLabels() {
        
        if let font = digitalTimerLabel.font {
            digitalTimerLabel.font = UIFont(name: font.fontName, size: maximumSizeOfDigitalTimerLabel)
        }
        if let font  = dayAndDateLabel.font {
            dayAndDateLabel.font = UIFont(name: font.fontName, size: maximumSizeOfDayAndDateLabel)
        }
        if let font = welcomeMessageLabel.font {
            welcomeMessageLabel.font = UIFont(name: font.fontName, size: maximumSizeOfWelcomeMessageLabel)
        }
    }
    
    
    /**
     This is a convenience method to convert time in 12 hour format.
     
     - parameter hour: The hour to be converted into 12 hour format.
     
     - returns: Returns a converted time.
     */
    func getHourAs12HourFormat(forhour hour: Int) -> Int {
        
        return hour > 12 ? hour - 12 : hour
        
    }
    
    /**
     This is a convenince method to adujust font size based on translation.
     
     - parameter label:              The labal to reset
     - parameter translation:        The pan gesture translation in view
     - parameter maximumSizeOfLabel: Maximum size to be set to a label when translation is crossed maiximum limit
     */
    func adjustFontSizeOfLabel(forLabel label:UILabel, translation: CGFloat, maximumSizeOfLabel: CGFloat) {
        var fontSizeLabel = label.font.pointSize + translation
        fontSizeLabel = fontSizeLabel > maximumSizeOfLabel ? maximumSizeOfLabel : fontSizeLabel
        fontSizeLabel =  fontSizeLabel < minmumSizeLabel ? minmumSizeLabel : fontSizeLabel
        if let font = label.font {
            label.font = UIFont(name: font.fontName, size: fontSizeLabel)
        }
    }
    
    /**
     This is a convenience method set a text to welcome message label.
     */
    func setWelcomeMessageLabel() {
        self.welcomeMessageLabel.text = "Welcome Guest"
        FirebaseNetworkManager.sharedInstance.getUserName { (userName: String) -> Void in
            if !userName.isEmpty {
                self.welcomeMessageLabel.text = "Welcome " + userName
            }
            else {
                self.welcomeMessageLabel.text = "Welcome Guest"
            }
        }
        
    }
    
    func setUpWeekDayNameDictionary() {
        
        weekDayNames = [ 1 : "Sun",  2 : "Mon",  3 : "Tue",  4 : "Wed",  5 : "Thr",  6 : "Fri",  7 : "Sat"]
    }
    
    
    /**
     This is usefulll method to set a formatted date to date label.
     
     - parameter calender: Current user calender
     - parameter date:     Current date
     */
    func setFormattedDate(formCalender calender: NSCalendar, date: NSDate) {
        let year = calender.component(NSCalendarUnit.Year, fromDate: date)
        let month = calender.component(.Month, fromDate: date)
        let day = calender.components(NSCalendarUnit.Day, fromDate: date)
        let weekDay = calender.components(NSCalendarUnit.Weekday, fromDate: date)
        let intWeekDay = weekDay.weekday
        let dayName = weekDayNames[intWeekDay] ?? ""
        let dayInInt = day.day
        
        let currentDate = String(dayInInt)   + "-" + String(month) + "-" + String(year)
        let dayAndDate = dayName + ", " + String(currentDate)
        dayAndDateLabel.text = dayAndDate
    }
    
}




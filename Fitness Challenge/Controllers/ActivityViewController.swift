//
//  ViewController.swift
//  Fitness Challenge
//
//  Created by Kieran Andrews on 8/10/2015.
//  Copyright © 2015 Kieran Andrews. All rights reserved.
//

import UIKit
import SwiftyJSON
import Eureka
import Mixpanel
import LoginKit

import SVProgressHUD

class ActivityViewController: FormViewController {
    
    var activities: [Activity] = []
    var logs: [Log] = []
    var activity_section: Section = Section()
    var announcement_section: Section = Section()
    
    override func viewDidLoad() {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("Opened activity")
        super.viewDidLoad()
        getActivities()
        
        self.title = "Log Activity"
        let logoutButton : UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ActivityViewController.logout(_:)))
        self.navigationItem.leftBarButtonItem = logoutButton
        
        let customView = UIView(frame: self.view.frame)
        customView.backgroundColor = Appearance.whiteColour
    }
    
    func updateInterface(){
        
        let submitButton : UIBarButtonItem = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ActivityViewController.submitActivity(_:)))
        self.navigationItem.rightBarButtonItem = submitButton
        
        
        
        var options = [String]()
        for activity in activities {
            options.append(activity.name)
        }
        let segmentedRow = SegmentedRow<String>("segments"){
            $0.options = options
            $0.value = options[0]
        }
        
        let quantity_row = IntRow("quantity"){ $0.title = "Amount"; $0.value = 1 }.onCellSelection { cell, row in
            cell.textField.selectAll(nil)
        }.onCellHighlight { cell, row in
            cell.textField.selectAll(nil)
        }
        var team_name = "Not Assigned Yet"
//        if let label = LoginService.user?.team{
//            team_name = label
//        }
        team_name = "Loading"
        
        let days: [String] = ["Today", "Yesterday"]
        
        form +++ Section("Activity")
            <<< segmentedRow
            <<< ActionSheetRow<String>("day") {$0.title = "Day"; $0.value = days[0]; $0.options = days}
            <<< quantity_row
//            <<< ActionSheetRow<String>("team") {$0.title = "Team"; $0.value = team_name; $0.options = [team_name]}
            <<< LabelRow("team"){$0.title = "Team"; $0.value = team_name}
        
        announcement_section = Section("Announcement")
        form +++ announcement_section
        
        activity_section = Section("Previous Activities")
        form +++ activity_section
        
    }
    
    
    func getLogs(){
        
        LoginService.request(.GET, "logs")
            .responseJSON() { response in
                
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    NSLog("GET Result: \(json)")
                    self.didReceiveLogResult(json)
                    self.navigationItem.rightBarButtonItem?.enabled = true
                } else {
                    self.showErrorView(true,
                        animated: false,
                        title: response.result.error!.localizedFailureReason,
                        subtitle: response.result.error!.localizedDescription)
                    NSLog("\(response.result.error)")
                    
                }
                self.showLoadingView(false, animated: true)
            }
        
    }
    
    func getUser(){
        
        LoginService.request(.GET, "login")
            .responseJSON() { response in
                
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    let current_user = LoginService.user
                    let downloaded_team_name = json["data"]["team"].stringValue
                    // TODO: implement team
//                    current_user.team = downloaded_team_name
                    self.form.setValues(["team": downloaded_team_name])
                    self.tableView!.reloadData()
                    LoginService.user! = current_user!
                
                } else {
                    NSLog("\(response.result.error)")
                    
                }
            }
        
    }
    
    func getAnnouncement(){
        
        LoginService.request(.GET, "event")
            .responseJSON() { response in
                
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    NSLog("GET Result: \(json)")
                    self.didReceiveAnnouncementResult(json)
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }else {
                    self.showErrorView(true,
                        animated: false,
                        title: response.result.error!.localizedFailureReason,
                        subtitle: response.result.error!.localizedDescription)
                    NSLog("\(response.result.error)")
                    
                }
                self.showLoadingView(false, animated: true)
            }
        
    }
    
    
    func submitActivity(sender: UIBarButtonItem){
        let values = form.values()
        let quantityRow = form.rowByTag("quantity")
        var outsideQuantity: String = ""
        if let quantity = quantityRow?.baseValue {
            outsideQuantity = String(quantity)
        }
        let activity_name = values["segments"] as! String
        var found_activity_id: Int = 0
        for activity in activities {
            if (activity.name == activity_name){
                if let activity_id = Int(activity.id) {
                    found_activity_id = activity_id
                }
                
            }
        }
        var parameters = [String: AnyObject]()
        parameters["amount"] = outsideQuantity
        parameters["activity_id"] = found_activity_id
        
        let day_name = values["day"] as! String
        if (day_name == "Yesterday"){
            parameters["yesterday"] = true
        }
        
        var params = [String : [String : AnyObject]]()
        params["log"] = parameters
        
        SVProgressHUD.show()
        
        LoginService.request(.POST, "logs", parameters: params)
            .responseJSON() { response in
                
                if response.result.isSuccess {
                    SVProgressHUD.showSuccessWithStatus("Activity saved")
                    self.getLogs()
                    let json = JSON(response.result.value!)
                    NSLog("GET Result: \(json)")
                } else {
                    NSLog("\(response.result.error)")
                    SVProgressHUD.showErrorWithStatus("Could not save activity")
                }
                
            }
    }
    
    func getActivities(){
        
        LoginService.request(.GET, "activities")
            .responseJSON() { response in
                
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    NSLog("GET Result: \(json)")
                    self.didReceiveResult(json)
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
                
//                if let error = response.result.error as NSError? {
//                    self.showErrorView(true,
//                        animated: false,
//                        title: error.localizedFailureReason,
//                        subtitle: error.localizedDescription)
//                    NSLog("\(error)")
//                    
//                } else if let jsonObj = response.result.value {
//                    let json = JSON(jsonObj)
//                    NSLog("GET Result: \(json)")
//                    self.didReceiveResult(json)
//                    self.navigationItem.rightBarButtonItem?.enabled = true
//                }
                
                self.showLoadingView(false, animated: true)
            }
    }
    
    func didReceiveResult(result: JSON){
        
        for (_, event) in result["data"] {
            activities.append(Activity(id: event["id"].stringValue, name: event["title"].stringValue))
        }
        
        self.getLogs()
        self.getAnnouncement()
        self.updateInterface()
        self.getUser()
        
    }
    
    func didReceiveLogResult(result: JSON){
        
        logs = []
        for (_, event) in result["data"] {
            logs.append(Log(id: event["id"].stringValue, activity_id: event["activity_id"].stringValue, amount: event["amount"].stringValue, date: event["inserted_at"].stringValue))
        }
        
        logs = logs.reverse()
        
        var logsTwenty: [Log] = []
        
        outerLoop: for (index, log) in logs.enumerate() {
            logsTwenty.append(log)
            if (index > 18) {
                break outerLoop
            }
        }
        
        activity_section.removeAll()
        for log in logsTwenty {
            var activity_name = ""
            for activity in self.activities {
                if (activity.id == log.activity_id){
                    activity_name = activity.name
                }
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
            let date = dateFormatter.dateFromString(log.date)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM - EEE, hh:mm a"
            formatter.timeZone = NSTimeZone(abbreviation: "ACST")
            
            let dateString = formatter.stringFromDate(date!)
            
            activity_section
                <<< LabelRow() { $0.title = activity_name + " x " + log.amount; $0.value = dateString}
        }
        
        
    }
    
    func didReceiveAnnouncementResult(result: JSON){
        let announcement_string = result["data"]["announcement"].stringValue
        if (announcement_string != ""){
            announcement_section
                <<< LabelRow() { $0.title = announcement_string; $0.cellStyle = .Default }.onCellSelection { cell, row in
                    let alert = UIAlertController(title: "Announcement", message: announcement_string, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
            }
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logout(sender: UIBarButtonItem){
        LoginService.logoff()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var loadingIndicatorView = LoadingView()
    var errorView = ErrorView()
    
    
    func showLoadingView(setVisible: Bool, animated: Bool) {
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        if setVisible {
            self.loadingIndicatorView.show(animated)
        } else {
            self.loadingIndicatorView.hide(animated)
        }
    }
    
    func showErrorView(setVisible: Bool, animated: Bool, title: String?=nil, subtitle: String?=nil) {
        self.view.bringSubviewToFront(self.errorView)
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.errorView.setText(title, subtitle: subtitle)
        
        // TODO: Need to stop loop due to autologin
        let alert = UIAlertController(title: "Erorr", message: "There was an error loading the content. Check your internet connection", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        // Services.logout()
//        dismissViewControllerAnimated(true, completion: nil)
        

        if setVisible {
            self.errorView.show(animated)
        } else {
            self.errorView.hide(animated)
        }
    }
    
    
}


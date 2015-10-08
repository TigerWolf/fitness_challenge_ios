//
//  ServicesController.swift
//  StudentExperienceMonitor
//
//  Created by Andreas Wulf on 19/08/2015.
//  Copyright (c) 2015 Adelaide University. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Rollbar

let Services = ServicesController.sharedInstance

class ServicesController {
    
    static let sharedInstance = ServicesController()
    
    static var url: String {
        #if RELEASE
            return "http://45.55.74.119:4001/"
            #else
            return "http://45.55.74.119:4001/"
        #endif
    }
    
    static var apiV1Path: String {
        return ServicesController.url + "api/v1/"
    }
    
    let appDir: String! = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
    
    var storePassword = false
    
    var termsInfo: JSON?
    
    var user: User? {
        didSet {
            if let appDir = self.appDir {
                if user != nil {
                    if NSKeyedArchiver.archiveRootObject(user!, toFile: appDir + "/user") == false {
                        Rollbar.criticalWithMessage("Failed to save user object")
                    }
                } else {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(appDir + "/user")
                    } catch {
                        Rollbar.criticalWithMessage("Failed to delete user object")
                    }
                }
            }
        }
    }
    
    // App Settings (both server and user controlled)
    var settings: Settings {
        didSet {
            self.saveSettings()
        }
    }
    
    func saveSettings() {
        if let appDir = self.appDir {
            if NSKeyedArchiver.archiveRootObject(settings, toFile: appDir + "/settings") == false {
                Rollbar.criticalWithMessage("Failed to save settings object")
            }
        }
    }
    
    init() {
        if let appDir = self.appDir, user = NSKeyedUnarchiver.unarchiveObjectWithFile(appDir + "/user") as? User {
            self.user = user
        }
        
        if let appDir = self.appDir, settings = NSKeyedUnarchiver.unarchiveObjectWithFile(appDir + "/settings") as? Settings {
            self.settings = settings
        } else {
            self.settings = Settings()
        }
        
    }
    
    func request(method: Alamofire.Method, _ path: String, parameters: [String : AnyObject]? = nil) -> Alamofire.Request {
        
        let location = ServicesController.apiV1Path + path
        let manager = Alamofire.Manager.sharedInstance
        
        var request = manager.request(method, location, parameters: parameters, encoding: .JSON)
        
        if let username = self.user?.username, let password = self.user?.password {
            request = request.authenticate(user: username, password: password)
        }
        
        // Listen to all the responses
        request.responseAPI({ (request, response, result) -> Void in
            if let error = result.error as? NSError {
                // -999 is Operation cancelled, which is reported when an authentication challenge has failed
                // Unfortunately can't get out the 401 Unauthoriszed from the Alamofire response
                if error.code == -999 {
                    Rollbar.warningWithMessage("Authentication Error", data: ["logged_in": (Services.user?.password != nil)])
                    
                    self.logout()
                    
                    if let viewController = UIApplication.sharedApplication().windows.first?.rootViewController as? LoginViewController
                        where !(viewController.presentedViewController is UIAlertController) {
                            viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                                NSLog("GET Error: \(error)")
                                
                                let alert = UIAlertController(
                                    title: "Authentication Failed",
                                    message: "Please try to sign in again",
                                    preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                viewController.presentViewController(alert, animated: true, completion: nil)
                            })
                    }
                    
                } else {
                    var data = Dictionary<String, AnyObject>()
                    if let text: AnyObject = error.userInfo[NSLocalizedDescriptionKey] {
                        data[NSLocalizedDescriptionKey] = text
                    }
                    if let text: AnyObject = error.userInfo[NSLocalizedFailureReasonErrorKey] {
                        data[NSLocalizedFailureReasonErrorKey] = text
                    }
                    if let url = request?.URL?.absoluteString {
                        data["url"] = url
                    }
                    data["errorCode"] = error.code
                    
                    Rollbar.criticalWithMessage("Request Error", data: data)
                }
            }
        })
        
        return request
    }
    
    func logout() {
        self.user?.clearPassword()
        self.user = nil
        self.settings = Settings()
    }
    
    func isLoggedIn() -> Bool {
        if self.user?.password != nil && self.user?.username != nil {
            return true
        }
        
        return false
    }
    
    
    // MARK: - Version/API Services checking
    
    var lastDisplayedDate: NSDate?
    var lastWarningMessage: String?
    var displayedCheckVersionAlert: UIAlertController?
    
    func checkAPI() {
        if let bundleShortVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        {
            let manager = Alamofire.Manager.sharedInstance
            var checkURL = ServicesController.url + "pub-api/v1/check_message?build_number=\(bundleVersion)&version=\(bundleShortVersion))"
            
            if self.isLoggedIn() {
                checkURL += "&username=\(self.user!.username)"
            }
            
            manager.request(.GET, checkURL).responseAPI({ (request, response, result) -> Void in
                if let error = result.error as? NSError {
                    NSLog("GET Error: \(error)")
                    
                } else if let jsonR: AnyObject = result.value {
                    let jsonObj = JSON(jsonR)
                    
                    NSLog("GET Result: \(jsonObj)")
                    
                    self.settings.setServicesSettings(jsonObj["settings"])
                    self.saveSettings()
                    
                    let message = jsonObj["message"].stringValue
                    let blocking = jsonObj["blocking"].bool
                    
                    var alertController: UIAlertController?
                    
                    if let urlString = jsonObj["url"].string, let url = NSURL(string: urlString) {
                        // If there is a URL, need to show it, means a new version is available
                        
                        alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                        alertController?.addAction(UIAlertAction(title: "Upgrade", style: .Default, handler: { (action) -> Void in
                            UIApplication.sharedApplication().openURL(url)
                        }))
                        
                        // This isn't a warning
                        self.lastWarningMessage = nil
                        
                    } else if message.characters.count > 0 {
                        // If there is a message, there is a warning to show at least
                        
                        let lastMassageEqual = (self.lastWarningMessage == message)
                        self.lastWarningMessage = message
                        
                        // Don't display if the warning had already been displayed within the last hour
                        var showBasedOnTime = true
                        if let displayedDate = self.lastDisplayedDate where displayedDate.timeIntervalSinceNow > (-(60.0 * 60 * 1)) {
                            showBasedOnTime = false
                        }
                        
                        // Only show if it's a new message OR it's time to show the message again OR its a blocking view
                        if !lastMassageEqual || (lastMassageEqual && showBasedOnTime) || blocking == true {
                            alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                        }
                        
                        if blocking != true {
                            alertController?.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alert) -> Void in
                                self.displayedCheckVersionAlert = nil
                            }))
                        } else {
                            // Blocking isn't a warning
                            self.lastWarningMessage = nil
                        }
                        
                    } else {
                        // If there is nothing, make sure to remove displayed alert
                        self.displayedCheckVersionAlert?.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.displayedCheckVersionAlert = nil
                        })
                    }
                    
                    
                    if let alertControllerToShow = alertController {
                        // Remove previous alert view if shown
                        self.displayedCheckVersionAlert?.dismissViewControllerAnimated(false, completion: { () -> Void in
                        })
                        
                        let viewController: UIViewController? = UIApplication.sharedApplication().windows.first?.rootViewController
                        viewController?.presentViewController(alertControllerToShow, animated: true, completion: { () -> Void in
                            self.lastDisplayedDate = NSDate()
                            self.displayedCheckVersionAlert = alertControllerToShow
                        })
                    }
                }
                
            })
        }
    }
}


// MARK: - API Response Serializer

extension Request {
    
    public static func APIResponseSerializer(
        options options: NSJSONReadingOptions = .AllowFragments)
        -> GenericResponseSerializer<AnyObject>
    {
        return GenericResponseSerializer { request, response, data in
            if let httpError = response?.error {
                return .Failure(nil, httpError)
            }
            
            guard let validData = data else {
                let failureReason = "JSON could not be serialized because input data was nil."
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
            }
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(validData, options: options)
                return .Success(JSON)
            } catch {
                return .Failure(data, error as NSError)
            }
        }
    }
    
    public func responseAPI(
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<AnyObject>) -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.APIResponseSerializer(options: .AllowFragments),
            completionHandler: completionHandler
        )
    }
}
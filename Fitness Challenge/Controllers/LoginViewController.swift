//
//  LoginController.swift
//
//  Created by a1673450 on 6/05/2015.
//  Copyright (c) 2015 adelaide. All rights reserved.
//

import UIKit
import QuartzCore
//import SVProgressHUD
import SwiftyJSON

class LoginViewController: UIViewController {
    
    var center_coords: CGFloat {
        return (self.view.frame.size.width/2) - (235/2)
    }
    
    var username: UITextField = UITextField()
    var password: UITextField = UITextField()
    
    var mainGradient: CAGradientLayer?
    
    var savePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let the_header = header()
        view.addSubview(the_header)
        
        view.backgroundColor = Appearance.blueColour
        
        self.username = build_field("Username", top: 250)
        self.password = build_field("Password", top: 320)
        self.password.secureTextEntry = true
        self.view.addSubview(self.username)
        self.view.addSubview(self.password)
        
        self.savePasswordButton = UIButton()
        self.savePasswordButton.setTitle("Save Password", forState: .Normal)
        let normalImage = UIImage(named: "icon_unchecked")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let selectedImage = UIImage(named: "icon_checked")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.savePasswordButton.setImage(normalImage, forState: .Normal)
        self.savePasswordButton.setImage(selectedImage, forState: .Selected)
        self.savePasswordButton.imageView?.tintColor = Appearance.whiteColour
        self.savePasswordButton.addTarget(self, action: "savePasswordTapped", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.savePasswordButton)
        self.savePasswordButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        self.savePasswordButton.titleLabel?.font = self.password.font
        self.savePasswordButton.frame = CGRectMake(
            self.password.frame.minX,
            self.password.frame.maxY + 3,
            self.password.frame.width,
            self.password.frame.height)
        self.savePasswordButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, self.savePasswordButton.frame.width - (normalImage.size.width + 40.0), 0.0, 0.0)
        self.savePasswordButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, normalImage.size.width + 30);
        
        let login = UIButton(type: UIButtonType.System)
        login.setTitle("Login", forState: UIControlState.Normal)
        login.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        login.setTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal)
        login.clipsToBounds = true
        login.layer.cornerRadius = 5
        login.sizeToFit()
        login.layer.borderColor = Appearance.whiteColour.CGColor
        login.layer.borderWidth = 1.0
        login.backgroundColor = Appearance.redColour
        login.frame = CGRectMake(center_coords, self.savePasswordButton.frame.maxY + 3, 235, 50)
        login.addTarget(self,
            action: "perform_login:",
            forControlEvents: UIControlEvents.TouchUpInside)
        login.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        self.view.addSubview(login)
    }
    
    func header() -> UIView {
        let view:UIView = UIView()
        view.frame = self.view.bounds
        let myImage = UIImage(named: "logo_uofa")
        let imageView = UIImageView(image: myImage)
        
        var imageFrame = imageView.frame
        imageFrame.size.height = 250
        imageFrame.size.width = self.view.frame.size.width
        imageView.frame = imageFrame
        view.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        
        imageView.contentMode = .ScaleAspectFit
        imageView.bounds = CGRectInset(imageView.frame, 10.0, 10.0)
        view.addSubview(imageView)
        return view
    }
    
    func build_field(name: String, top: CGFloat) -> UITextField {
        let field = UITextField()
        field.sizeToFit()
        let placeholderText = name
        let attrs = [NSForegroundColorAttributeName : UIColor.grayColor()]
        let placeholderString = NSMutableAttributedString(string: placeholderText, attributes:attrs)
        field.attributedPlaceholder = placeholderString
        let cord: CGFloat = 235
        let width: CGFloat = 50
        field.frame = CGRectMake(center_coords, top, cord, width)
        field.borderStyle = UITextBorderStyle.RoundedRect
        
        // Enhancements
        field.autocorrectionType = UITextAutocorrectionType.No
        field.autocapitalizationType = UITextAutocapitalizationType.None
        field.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        
        return field
    }
    
    func doneWithInput(sender: UIBarButtonItem){
        // TODO: Implement next field [tab] button.
        
        // Close keyboard here
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
    }
    
    func perform_login(Sender: UIButton!) {
        
        if let username = self.username.text, let password = self.password.text
            where username.characters.count > 0 && password.characters.count > 0 {
                
                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
                Services.request(.GET, "login").authenticate(user: username, password: password)
                    .responseAPI({ (request, response, result) -> Void in
                        SVProgressHUD.dismiss()
                        
                        var alert: UIAlertController?
                        
                        if let error = result.error as? NSError {
                            // -999 is Operation cancelled, which is reported when an authentication challenge has failed
                            // Unfortunately can't get out the 401 Unauthoriszed from the Alamofire response
                            if error.code == -999 {
                                
                                alert = UIAlertController(
                                    title: "Authentication Failed",
                                    message: "Please check your username and password and try again",
                                    preferredStyle: UIAlertControllerStyle.Alert)
                                
                                
                            } else {
                                // It's another error, show the message
                                alert = UIAlertController(
                                    title: "Authentication Failed",
                                    message: error.localizedDescription,
                                    preferredStyle: UIAlertControllerStyle.Alert)
                            }
                            
                        } else {
                            NSLog("GET Result: \(result.value)")
                            
                            if let jsonObj: AnyObject = result.value {
                                var json = JSON(jsonObj)
                                
                                Services.user = User(id: json["data"]["id"].stringValue, username: username, team: json["data"]["team"].stringValue)
                                Services.user?.password = password
                                
                                // Refresh the details for user specific info
                                Services.checkAPI()
                                
                                self.proceedToNextBoard()
                                
                            } else {
                                alert = UIAlertController(
                                    title: "Authentication Failed",
                                    message: "Unknown error, please try again",
                                    preferredStyle: UIAlertControllerStyle.Alert)
                            }
                        }
                        
                        if let alertVC = alert {
                            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alertVC, animated: true, completion: nil)
                        }
                    })
                
        } else {
            let alert = UIAlertController(title: nil, message: "Please enter your username and password", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func proceedToNextBoard() {
        let viewController = ActivityViewController()
        let navigationController = NavController(rootViewController: viewController)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.dismiss()
        
        if let password = Services.user?.password, let username = Services.user?.username where
            password.characters.count > 0 && username.characters.count > 0
        {
            Services.checkAPI()
            self.proceedToNextBoard()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.username.text = Services.user?.username
        self.password.text = Services.user?.password
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func savePasswordTapped() {
        self.savePasswordButton.selected = !self.savePasswordButton.selected
        Services.storePassword = self.savePasswordButton.selected
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return UIInterfaceOrientationMask.All
        }
        
        return UIInterfaceOrientationMask.Portrait
    }
}

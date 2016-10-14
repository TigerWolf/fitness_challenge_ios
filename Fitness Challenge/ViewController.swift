//
//  ViewController.swift
//  Fitness Challenge
//
//  Created by Kieran Andrews on 8/10/2015.
//  Copyright © 2015 Kieran Andrews. All rights reserved.
//

import UIKit
import LoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Setup
        LoginKitConfig.url = "https://challengecup.club/api/v1/"
        LoginKitConfig.loginPath = "login" // TODO: Remove this for basic auth - or create endpoint?
        LoginKitConfig.authType = AuthType.Basic
        LoginKitConfig.savedLogin = true
        LoginKitConfig.destination = { () -> UIViewController in ActivityNavController() }
        LoginKitConfig.logoImage = UIImage(named: "logo") ?? UIImage()
        
        let appearance = LoginKit.Appearance()
        appearance.backgroundColor = UIColor(hue: 0.5742, saturation: 0.7309, brightness: 0.9765, alpha: 1.0)
        appearance.buttonColor = UIColor(hue: 0.1333, saturation: 1, brightness: 1, alpha: 1.0)
        appearance.buttonBorderColor = UIColor(hue: 0.0972, saturation: 0.77, brightness: 0.93, alpha: 1.0)
        
        let loginScreen = LoginKit.loginScreenController() as! LoginController
        self.presentViewController(loginScreen, animated: animated,completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


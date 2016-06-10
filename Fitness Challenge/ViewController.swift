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
        LoginKitConfig.url = "https://challengecup.club/"
        LoginKitConfig.loginPath = "api/v1" // TODO: Remove this for basic auth - or create endpoint?
        LoginKitConfig.authType = AuthType.Basic
        LoginKitConfig.savedLogin = true
        //        LoginKitConfig.destination = { ()-> UIViewController in JobViewController() }
        LoginKitConfig.destination = { () -> UIViewController in ActivityViewController() }
        LoginKitConfig.logoImage = UIImage(named: "logo") ?? UIImage()
        
        LoginKit.Appearance().backgroundColor = UIColor(hue: 0.5694, saturation: 1, brightness: 0.61, alpha: 1.0)
        
        let login_screen = LoginKit.loginScreenController() as! LoginController
        self.presentViewController(login_screen, animated: animated,completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


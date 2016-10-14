//
//  Appearance.swift
//  StudentExperienceMonitor
//
//  Created by Andreas Wulf on 24/08/2015.
//  Copyright (c) 2015 Adelaide University. All rights reserved.
//

import UIKit
import SVProgressHUD

let Appearance = AppearanceController.sharedInstance

class AppearanceController {
    
    static let sharedInstance = AppearanceController()
    
    let blueColour = UIColor(hue: 0.5694, saturation: 1, brightness: 0.61, alpha: 1.0)
    let redColour = UIColor(hue: 0.9861, saturation: 0.88, brightness: 0.92, alpha: 1.0)
    let whiteColour = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
    let blackColour = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 1.0)
    let goldColour = UIColor(hue: 0.1222, saturation: 0.95, brightness: 0.7, alpha: 1.0)
    let greyColour = UIColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1.0)
    
    let blueLightColour = UIColor(hue: 0.5694, saturation: 0.66, brightness: 0.79, alpha: 1.0)
    let blueDarkColour = UIColor(hue: 0.575, saturation: 0.99, brightness: 0.45, alpha: 1.0)
    
    // Edge Padding
    let lpad: CGFloat = 16.0
    // Small Padding
    let spad: CGFloat = 8.0
    
    init() {
        UINavigationBar.appearance().barTintColor = self.blueColour
        UINavigationBar.appearance().tintColor = self.whiteColour
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:self.whiteColour]
        
        UISegmentedControl.appearance().tintColor = self.blueColour
        
        // Table settings
        UITableViewHeaderFooterView.appearance().tintColor = blueColour
        UITableView.appearance().separatorColor = whiteColour
        UITableViewCell.appearance().tintColor = blueColour
        
        SVProgressHUD.setBackgroundColor(self.whiteColour)
        SVProgressHUD.setForegroundColor(self.blueColour)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setRingThickness(3.0)
        
    }    
}


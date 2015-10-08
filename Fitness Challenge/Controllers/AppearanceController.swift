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
    
    let blueColour = UIColor(rgba: "#005a9c")
    let redColour = UIColor(rgba: "#ed1c2e")
    let whiteColour = UIColor(rgba: "#FFFFFF")
    let blackColour = UIColor(rgba: "#000000")
    let goldColour = UIColor(rgba: "#b38808")
    let greyColour = UIColor(rgba: "#666666")
    
    let blueLightColour = UIColor(rgba: "#4391ca")
    let blueDarkColour = UIColor(rgba: "#013f74")
    
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
        UITableView.appearance().separatorColor = whiteColour.darkerColor(0.05)
        UITableViewCell.appearance().tintColor = blueColour
        
        SVProgressHUD.setBackgroundColor(self.whiteColour)
        SVProgressHUD.setForegroundColor(self.blueColour)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setRingThickness(3.0)
        
    }    
}


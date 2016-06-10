//
//  ActivityModel.swift
//  Fitness Challenge
//
//  Created by Kieran Andrews on 9/10/2015.
//  Copyright © 2015 Kieran Andrews. All rights reserved.
//


import Foundation


class Activity: NSObject {
    let id: String
    let name: String
    
    init(id: String,name: String){
        self.id = id        
        self.name = name
    }
}
//
//  LogModel.swift
//  Fitness Challenge
//
//  Created by Kieran Andrews on 13/10/2015.
//  Copyright © 2015 Kieran Andrews. All rights reserved.
//

import Foundation

class Log: NSObject {
    let id: String
    let activity_id: String
    let amount: String
    let date: String
    
    init(id: String,activity_id: String, amount: String, date: String){
        self.activity_id = activity_id
        self.id = id
        self.amount = amount
        self.date = date
    }
}
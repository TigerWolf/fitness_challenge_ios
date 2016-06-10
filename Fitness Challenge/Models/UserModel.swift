//
//  UserModel.swift
//  StudentExperienceMonitor
//
//  Created by Andreas Wulf on 21/08/2015.
//  Copyright (c) 2015 Adelaide University. All rights reserved.
//

import Foundation
import KeychainAccess
//import Rollbar

class User: NSObject, NSCoding {
    
    let id: String
    let username: String
    var firstName: String?
    var lastName: String?
    var team: String?
    var email: String?
    var mobile: String?
    var phone: String?
    
    let keychain = Keychain(service: "au.edu.adelaide")
    
    var password: String? {
        didSet {
            if Services.storePassword {
                // Store to keychain
                if password != nil {
                    do {
                        try keychain.set(password!, key: "password")
                    } catch {
//                        Rollbar.warningWithMessage("Failed to set password")
                    }
                } else {
                    self.clearPassword()
                }
            }
        }
    }
    
    func clearPassword() {
        do {
            try keychain.remove("password")
        } catch {
//            Rollbar.warningWithMessage("Failed to clear password")
        }
    }
    
    init(id: String, username: String, team: String) {
        self.id = id
        self.username = username
        self.team = team
        
        // Set Person details
//        Rollbar.currentConfiguration().setPersonId(id, username: username, email: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        if let username = aDecoder.decodeObjectForKey("username") as? String,
            let id = aDecoder.decodeObjectForKey("id") as? String {
                self.id = id
                self.username = username
                
        } else {
            self.id = ""
            self.username = ""
        }
        
        self.firstName = aDecoder.decodeObjectForKey("firstName") as? String
        self.lastName = aDecoder.decodeObjectForKey("lastName") as? String
        self.email = aDecoder.decodeObjectForKey("email") as? String
        self.phone = aDecoder.decodeObjectForKey("phone") as? String
        self.mobile = aDecoder.decodeObjectForKey("mobile") as? String
        self.team = aDecoder.decodeObjectForKey("team") as? String
        
        do {
            if let password = try keychain.get("password") {
                self.password = password
            }
        } catch {
//            Rollbar.warningWithMessage("Failed to set password")
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.username, forKey: "username")
        
        if let firstName = self.firstName {
            aCoder.encodeObject(firstName, forKey: "firstName")
        }
        if let lastName = self.lastName {
            aCoder.encodeObject(lastName, forKey: "lastName")
        }
        if let email = self.email {
            aCoder.encodeObject(email, forKey: "email")
        }
        if let mobile = self.mobile {
            aCoder.encodeObject(mobile, forKey: "mobile")
        }
        if let phone = self.phone {
            aCoder.encodeObject(phone, forKey: "phone")
        }
        if let team = self.team {
            aCoder.encodeObject(team, forKey: "team")
        }
    }
    
    
    
}
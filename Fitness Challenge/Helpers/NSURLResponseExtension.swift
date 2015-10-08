//
//  NSURLResponseExtension.swift
//  StudentExperienceMonitor
//
//  Created by Andreas Wulf on 31/08/2015.
//  Copyright (c) 2015 Adelaide University. All rights reserved.
//

import Foundation

extension NSHTTPURLResponse {
    
    static var errorCodes: [Int: String] {
        return [
            400: "Bad Request",
            401: "Unauthorized",
            402: "Payment Required",
            403: "Forbidden",
            404: "Not Found",
            405: "Method Not Allowed",
            406: "Not Acceptable",
            407: "Proxy Authentication Required",
            408: "Request Timeout",
            409: "Conflict",
            410: "Gone",
            411: "Length Required",
            412: "Precondition Failed",
            413: "Request Entity Too Large",
            414: "Request-URI Too Long",
            415: "Unsupported Media Type",
            416: "Requested Range Not Satisfiable",
            417: "Expectation Failed",
            500: "Internal Server Error",
            501: "Not Implemented",
            502: "Bad Gateway",
            503: "Service Unavailable",
            504: "Gateway Timeout",
            505: "HTTP Version Not Supported"
        ]
    }
    
    var error: NSError? {
        get {
            print(statusCode, terminator: "")
            if statusCode >= 400 {
                let localizedDescription: String
                if let message = NSHTTPURLResponse.errorCodes[statusCode] {
                    localizedDescription = message + " (\(statusCode))"
                    
                } else {
                    localizedDescription = "Request Error (\(statusCode))"
                }
                
                return NSError(
                    domain: NSURLErrorDomain,
                    code: self.statusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey: localizedDescription,
                        NSLocalizedFailureReasonErrorKey: "Request Error"
                    ])
            }
            
            return nil
        }
    }
}
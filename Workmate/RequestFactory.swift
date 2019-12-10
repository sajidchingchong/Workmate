//
//  RequestFactory.swift
//  Workmate
//
//  Created by Profile1 on 8/12/19.
//  Copyright © 2019 Profile1. All rights reserved.
//

import UIKit

class RequestFactory: NSObject {

    static let baseUrl: String = "https://api.helpster.tech/v1/"
    
    static func login() -> (URLRequest, Data) {
        let request = postRequest(url: URL(string: baseUrl + "auth/login/")!)
        
        let json = [
            "username": "+6281313272005",
            "password": "alexander"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        return (request, jsonData)
    }
    
    static func staff(key: String) -> URLRequest {
        return URLRequest(url: URL(string: baseUrl + "staff-requests/26074/")!)
    }
    
    static func clockin(key: String) -> (URLRequest, Data) {
        var request = postRequest(url: URL(string: baseUrl + "staff-requests/26074/clock-in/")!)
        request.setValue("token " + key, forHTTPHeaderField: "Authorization")
        
        let json = [
            "latitude": "-6.2446691",
            "longitude": "106.8779625"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        return (request, jsonData)
    }
    
    static func clockout(key: String) -> (URLRequest, Data) {
        var request = postRequest(url: URL(string: baseUrl + "staff-requests/26074/clock-out/")!)
        request.setValue("token " + key, forHTTPHeaderField: "Authorization")
        
        let json = [
            "latitude": "-6.2446691",
            "longitude": "106.8779625"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        return (request, jsonData)
    }
    
    static func postRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}

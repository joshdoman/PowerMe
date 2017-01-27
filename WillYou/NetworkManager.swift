//
//  NetworkManager.swift
//  WillYou
//
//  Created by Josh Doman on 1/2/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//
import UIKit

class NetworkManager {
    static let serverUrl = "http://localhost:3000"
    
    static func sendChargerRequestToServer(request: Request, user: User) {
        
        let params = ["message": request.message!, "charger": request.charger!, "name": user.name!, "location": request.location!, "requesterId": user.uid!]
        let endUrl = "/notify/all"
        
        sendPostRequestToServer(endUrl: endUrl, params: params)
    }
    
    static func sendSuccessNotification(toToken: String, helperName: String) {
        let params = ["token": toToken, "message": "Congrats! \(helperName) can help."]
        let endUrl = "/notify/user"
        
        sendPostRequestToServer(endUrl: endUrl, params: params)
    }
    
    static func sendMessageNotification(toToken: String, message: String, fromName: String) {
        let params = ["token": toToken, "message": "\(fromName): \(message)"]
        let endUrl = "/notify/user"
        
        sendPostRequestToServer(endUrl: endUrl, params: params)
    }
    
    static func sendNotification(toToken: String, message: String) {
        let params = ["token": toToken, "message": message]
        let endUrl = "/notify/user"
        
        sendPostRequestToServer(endUrl: endUrl, params: params)
    }
    
    static func sendPostRequestToServer(endUrl: String, params: [String : String]) {
        let url = URL(string: "\(serverUrl)\(endUrl)")
        
        let urlRequest = NSMutableURLRequest(url: url!)
        
        urlRequest.httpMethod = "POST"
        do {
            
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: urlRequest as URLRequest, completionHandler: { (data, response, error) in
                //
                if let error = error {
                    print(error.localizedDescription)
                    
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        
                    }
                }
                
            })
            
            task.resume()
            
        } catch {
            
        }
    }
}

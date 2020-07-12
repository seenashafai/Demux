//
//  User.swift
//  Demux-v4
//
//  Created by Seena Shafai on 12/07/2020.
//

import Foundation
import Alamofire

struct User {
    
    func getUserInfo(endpoint: String) {
    //TODO: - add guard statement for accesstoken...
        AF.request(endpoint, method: .get, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer "+Session.globalSession.authToken!]).responseJSON { response in
            print(response.debugDescription)
            //Decode response as JSON
            if let result = response.value {
                let JSON = result as! NSDictionary
                print(JSON)
            }
        }
    }
}

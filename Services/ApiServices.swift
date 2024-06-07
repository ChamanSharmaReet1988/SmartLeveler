//
//  ApiServices.swift
//  smartleveler
//
//  Created by com on 23/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit
import Alamofire

class ApiServices: NSObject {
    let alomafire =  Alamofire.SessionManager.default
    
    func postservice (Url : String , _ parameters:[String : Any],completionHandler:  @escaping (_ success: NSDictionary?, _ error: NSError?) -> ()) {
        alomafire.session.configuration.timeoutIntervalForRequest = 60;
        alomafire.request(baseUrl + Url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let value):
                completionHandler(value as? NSDictionary, nil)
            case .failure(let error):
                completionHandler(nil, error as NSError)
            }
        }
    }
    
    func getservice (Urlstr : String ,completionHandler:  @escaping (_ success: NSDictionary?, _ error: NSError?) -> ()) {
        alomafire.session.configuration.timeoutIntervalForRequest = 60;
        alomafire.request(Urlstr, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                print("reponse ==", response.result.value!)
                if response.result.value != nil {
                    completionHandler(response.result.value as? NSDictionary, nil)
                } else if (response.result.error != nil) {
                    completionHandler(nil, response.result.error! as NSError)
                }
                break;
            case .failure(let encodingError):
                completionHandler(nil, encodingError as NSError)
                break;
            }
        }
    }
}

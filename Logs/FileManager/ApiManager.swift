//
//  ApiManager.swift
//  Logs
//
//  Created by apple  on 26/07/21.
//

import Foundation
class ApiManager {
    static let shared = ApiManager()
    private init() {}
    func callGetApi(completion: @escaping (_ result: [String:Any])->())
    {
        var request = URLRequest(url: URL(string: "http://localhost:3000/languageMessageResponse")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if (data == nil && error != nil)
            {
                completion(["success":false])
            }
            else
            {
                do
                    {
                        let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                        
                        print(json)
                        
                        completion(json)
                        
                    }
                catch
                {
                    completion(["success":false])
                }
            }
        })
        task.resume()
    }
}

//
//  ApiConnection.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import Foundation
import SystemConfiguration

//Singleton class that manage connections to API through all controllers
final class ApiConnection: NSObject
{
    
    //MARK: - LET / VAR DEFINITIONS
    static let shared = ApiConnection()//singleton object definition
    let api_routing : NSDictionary!//contains all urls to access webservices
    var api_responsable : ApiResponsable!//protocol definition
    var session_data_tasks_list = Dictionary<String, URLSessionDataTask>()//async api calls through sessions
    
    //MARK: - CLASS METHODS
    //Constructor
    private override init(){
        self.api_routing = Bundle.main.object(forInfoDictionaryKey: "ApiRouting") as! NSDictionary
    }
    
    //Protocol assignation
    func setApiResponsable(api_responsable : ApiResponsable){
        self.api_responsable = api_responsable
    }
    
    //Cancel connections with API
    func cancelarSessionDataTask(request_type : String){
        print("ApiConnection - cancelSessionDataTask")
        print("cancel task \(request_type)")
        let session_data_task = self.session_data_tasks_list[request_type]
        if session_data_task != nil {
            print("cancel session for task \(request_type)")
            self.session_data_tasks_list[request_type]!.cancel()
            print("task canceled success")
        }
        else{
            print("task to cancel not found")
        }
    }
    
    //Verify internet connection validating access to information
    func checkNetworkConnection() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    //Builds string to include in the header Authorization
    func getHeaderAuthorization()->String?{
        let access_token : String = Bundle.main.object(forInfoDictionaryKey: "access_token") as! String
        let header_authorization : String = "Bearer " + access_token
        return header_authorization
    }
    
    //MARK: - GET FUNCTIONS
    //sendGetRequest allows controllers to send GET request for the API
    func sendGetRequest(url_parameters : Dictionary<String, String>, aditional_parameters : Dictionary<String, String>){
        let plist_api_routing_name : String = aditional_parameters["plist_api_routing_name"]!
        let function_name_to_response : String = aditional_parameters["function_name_to_response"]!
        self.session_data_tasks_list[plist_api_routing_name] = URLSessionDataTask()
        
        var api_url = aditional_parameters["api_url"]!
        
        //including url parameters
        if url_parameters.count > 0 {
            api_url += "?"
            var index = 0
            for (parameter_type, parameter) in url_parameters {
                if index > 0 {
                    api_url += "&"
                }
                let string = parameter.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                api_url += parameter_type + "=" + string!
                index += 1
            }
        }
        print("api_url: \(api_url)")
        let url:NSURL = NSURL(string: api_url)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        if let header_authorization = self.getHeaderAuthorization(){
            request.setValue(header_authorization, forHTTPHeaderField: "Authorization")
        }
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //start request definition
        let session_configuration = URLSessionConfiguration.default
        session_configuration.timeoutIntervalForResource = TimeInterval(30)//wait for max 30 seconds for response
        session_configuration.timeoutIntervalForRequest = TimeInterval(30)
        let url_session = URLSession(configuration: session_configuration)
        self.session_data_tasks_list[plist_api_routing_name]! = url_session.dataTask(with: request as URLRequest){
            (json_data : Data?, response : URLResponse?, error : Error?) in
            var response_array = Dictionary<String, AnyObject>()
            let httpResponse = response as? HTTPURLResponse
            if error != nil {
                print("Error in request: \(String(describing: error?.localizedDescription))")
                let error_code = (error! as NSError).code
                response_array["error"] = error! as NSError
                response_array["error_message"] = "It wasn't possible to get the pictures at the moment. Please try again." as NSString
                response_array["response_code"] = error_code as AnyObject
                if error_code == -1012 {
                    //in ios, -1012 means NSURLErrorUserCancelledAuthentication
                    response_array["error_message"] = "Tu sesión ha finalizado." as NSString
                }
            }
            else{
                let response_code = httpResponse!.statusCode
                response_array["response_code"] = response_code as AnyObject
                switch response_code{
                case 200,201:
                    var json : Any? = nil
                    do {
                        json = try JSONSerialization.jsonObject(with: json_data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    } catch {
                        print("catch error")
                    }
                    if json == nil {
                        response_array["error"] = true as AnyObject
                        response_array["error_message"] = "It is possible that an error has happened. Please try again." as NSString
                    } else {
                        if let response = json as? Dictionary<String , AnyObject> {
                            response_array["response"] = response as AnyObject
                        } else if ((json as? Array<Dictionary<String, AnyObject>>) != nil) || ((json as? Array<String>) != nil) {
                            var response = Dictionary<String , AnyObject>()
                            response["items"] = json as AnyObject
                            response_array["response"] = response as AnyObject
                        } else {
                            let response = Dictionary<String,AnyObject>()
                            response_array["response"] = response as AnyObject
                        }
                        break
                    }
                case 401:
                    //access_token is expired
                    response_array["error"] = true as AnyObject
                    response_array["error_message"] = "Your session is finished. Update access token" as NSString
                    break
                case 404:
                    //Not found
                    response_array["error"] = true as AnyObject
                    response_array["error_message"] = "Information not found" as NSString
                    break
                default:
                    //Error accessing data
                    response_array["error"] = true as AnyObject
                    response_array["error_message"] = "It is possible that an error has happened. Please try again." as NSString
                    break
                }
            }
            print("sendGetRequest response code for \(plist_api_routing_name): \(String(describing: response_array["response_code"]))")
            DispatchQueue.main.async(execute: { () -> Void in
                self.api_responsable!.sendApiRequestFinished(response_array: response_array, function_name_to_response: function_name_to_response)
                self.session_data_tasks_list.removeValue(forKey: plist_api_routing_name)
                
            })
        }
        self.session_data_tasks_list[plist_api_routing_name]!.resume()
    }
    
}






//
//  ApiConnectionTest.swift
//  imgurTests
//
//  Created by Johan Hernandez on 4/19/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import XCTest
@testable import imgur

class ApiConnectionTest: XCTestCase, ApiResponsable  {
    //Testing connections to webservice
    
    var api_routing : NSDictionary!
    var api_page : Int = 1
    let text_to_search = "cat"//random word to send a request to the Webserver
    let test_webservice_response_expectation = XCTestExpectation(description: "Get imgur posts")
    //Api
    let api_connection = ApiConnection.shared//singleton object
    
    override func setUp() {
        super.setUp()
        //API
        self.api_connection.setApiResponsable(api_responsable: self)
        self.api_routing = Bundle.main.object(forInfoDictionaryKey: "ApiRouting") as! NSDictionary
    }
    
    //Check if the device is able to connect to internet
    func testInternetConection(){
        XCTAssertEqual(self.api_connection.checkNetworkConnection(), true)
    }
    
    //Check that the Webservice answer with no errors and includes the required elements
    func testWebserviceResponse(){
        var url_parameters : Dictionary<String, String> = [:]
        url_parameters["q"] = text_to_search
        
        //url definition
        let plist_api_routing_name = "uri_gallery"
        let page_string : String = String(self.api_page)
        var api_url : String = self.api_routing["url"] as! String
        let api_version : String = self.api_routing["api_version"] as! String
        api_url += api_version
        api_url += self.api_routing[plist_api_routing_name] as! String
        api_url += "/search/time/week/"+page_string
        
        var aditional_parameters : Dictionary<String, String> = [:]
        aditional_parameters["plist_api_routing_name"] = plist_api_routing_name
        aditional_parameters["function_name_to_response"] = "interpretResponseSearchPictures"
        aditional_parameters["api_url"] = api_url
        
        self.api_connection.sendGetRequest(url_parameters: url_parameters, aditional_parameters: aditional_parameters)
        
        // Wait until the expectation is fulfilled, with a timeout of 30 seconds.
        wait(for: [self.test_webservice_response_expectation], timeout: 30.0)
    }
    
    //sendApiRequestFinished is called after the app receive a response from the server
    func sendApiRequestFinished(response_array: Dictionary<String, AnyObject>, function_name_to_response: String) {
        XCTAssertNil(response_array["error"], "An error was found in the response")
        XCTAssertNotNil(response_array["response"], "No response found")
        XCTAssertNotNil(response_array["response_code"], "No response code found")
        if let response_code = response_array["response_code"] as? Int{
            XCTAssertEqual(response_code, 200, "The response code is not 200")
        }
        self.test_webservice_response_expectation.fulfill()
    }
    
}

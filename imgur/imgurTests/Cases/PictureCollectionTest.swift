//
//  PictureTest.swift
//  imgurTests
//
//  Created by Johan Hernandez on 4/19/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import XCTest
@testable import imgur

class PictureCollectionTest: XCTestCase, ApiResponsable {
    //Testing json structure sent by the webservice. It must be as expected. If a single element couldn't be read, an error will be displayed
    
    var api_routing : NSDictionary!
    var api_page : Int = 1
    let text_to_search = "cat"//random word to send a request to the Webserver
    let test_webservice_response_expectation = XCTestExpectation(description: "Get imgur posts")
    var picture_collection : PictureCollection = PictureCollection()
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
        if  let response_code = response_array["response_code"] as? Int,
            let response = response_array["response"]  as? Dictionary<String, Any>,
            response_code == 200,
            let json_pictures = response["data"] as? Array<Dictionary<String, AnyObject>>
        {
            self.picture_collection.createCollectionFromJsonArray(json_pictures: json_pictures)
            XCTAssertEqual(self.picture_collection.getErrorsJsonDataType(), [], "One or more objects could not be created")
        }
        
        
        self.test_webservice_response_expectation.fulfill()
    }
    
}

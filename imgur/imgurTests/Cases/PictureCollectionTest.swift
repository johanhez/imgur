//
//  PictureCollectionTest.swift
//  imgurTests
//
//  Created by Johan Hernandez on 4/19/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import XCTest
@testable import imgur

class PictureCollectionTest: XCTestCase, ApiResponsable {
    
    
    var api_routing : NSDictionary!
    var api_page : Int = 1
    let text_to_search = "cat"//random word to send a request to the Webserver
    let test_webservice_response_expectation_1 = XCTestExpectation(description: "Get imgur posts")
    let test_webservice_response_expectation_2 = XCTestExpectation(description: "Get imgur even posts")
    //Api
    let api_connection = ApiConnection.shared//singleton object
    
    override func setUp() {
        super.setUp()
        //API
        self.api_connection.setApiResponsable(api_responsable: self)
        self.api_routing = Bundle.main.object(forInfoDictionaryKey: "ApiRouting") as! NSDictionary
    }
    
    //Testing json structure sent by the webservice. It must be as expected. If a single element couldn't be read, an error will be displayed
    func testWebserviceJsonStructure(){
        print("testWebserviceJsonStructure")
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
        aditional_parameters["function_name_to_response"] = "interpretWebserviceJsonStructure"
        aditional_parameters["api_url"] = api_url
        
        self.api_connection.sendGetRequest(url_parameters: url_parameters, aditional_parameters: aditional_parameters)
        
        // Wait until the expectation is fulfilled, with a timeout of 30 seconds.
        wait(for: [self.test_webservice_response_expectation_1], timeout: 30.0)
    }
    
    //Check results. The sum of “points”, “score” and “topic_id” adds up to an even number
    func testWebserviceEvenResults(){
        print("testWebserviceEvenResults")
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
        aditional_parameters["function_name_to_response"] = "interpretValidateEvenResults"
        aditional_parameters["api_url"] = api_url
        
        self.api_connection.sendGetRequest(url_parameters: url_parameters, aditional_parameters: aditional_parameters)
        
        // Wait until the expectation is fulfilled, with a timeout of 30 seconds.
        wait(for: [self.test_webservice_response_expectation_2], timeout: 30.0)
    }
    
    //sendApiRequestFinished is called after the app receive a response from the server
    func sendApiRequestFinished(response_array: Dictionary<String, AnyObject>, function_name_to_response: String) {
        print("sendApiRequestFinished")
        if response_array["error"] == nil {
            switch function_name_to_response {
            case "interpretWebserviceJsonStructure":
                self.interpretWebserviceJsonStructure(response_array: response_array)
                break
            case "interpretValidateEvenResults":
                self.interpretValidateEvenResults(response_array: response_array)
                break
            default:
                break
            }
        }
    }
    
    func interpretWebserviceJsonStructure(response_array : Dictionary<String, AnyObject>){
        print("interpretWebserviceJsonStructure")
        if  let response_code = response_array["response_code"] as? Int,
            let response = response_array["response"]  as? Dictionary<String, Any>,
            response_code == 200,
            let json_pictures = response["data"] as? Array<Dictionary<String, AnyObject>>
        {
            let picture_collection : PictureCollection = PictureCollection()
            picture_collection.createCollectionFromJsonArray(json_pictures: json_pictures)
            XCTAssertEqual(picture_collection.getErrorsJsonDataType(), [], "The json structure for one or more elements could not be read")
        }
        self.test_webservice_response_expectation_1.fulfill()
    }
    
    func interpretValidateEvenResults(response_array : Dictionary<String, AnyObject>){
        print("interpretValidateEvenResults")
        if  let response_code = response_array["response_code"] as? Int,
            let response = response_array["response"]  as? Dictionary<String, Any>,
            response_code == 200,
            let json_pictures = response["data"] as? Array<Dictionary<String, AnyObject>>
        {
            let picture_collection : PictureCollection = PictureCollection()
            picture_collection._toggle_filter_is_on = true
            picture_collection.createCollectionFromJsonArray(json_pictures: json_pictures)
            print("last validation")
            for picture in picture_collection.getCollection() {
                XCTAssertEqual((picture.filter_sum_value % 2), 0, "Error aplying filter for even sum")
            }
        }
        self.test_webservice_response_expectation_2.fulfill()
    }
    
}

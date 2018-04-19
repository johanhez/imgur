//
//  PictureTest.swift
//  imgurTests
//
//  Created by Johan Hernandez on 4/19/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import XCTest
@testable import imgur

class PictureTest: XCTestCase {
    
    var picture : Picture? = nil
    
    override func setUp() {
        super.setUp()
        self.picture = Picture()
    }
    
    //Verify creation of object and use of getters and setters
    func testCreateObject() {
        XCTAssertNotNil(self.picture, "Object of type Picture could not be created")
    }
    
    func testSettersAndGetters() {
        let test_title = "test_title"
        let test_post_date = NSDate()
        let test_number_images : Int16 = 100
        let test_image_url = "http://imgur.com"
        let test_post_picture = #imageLiteral(resourceName: "test_happy")
        let filter_sum_value = 200
        
        self.picture!.title = test_title
        self.picture!.post_date = test_post_date
        self.picture!.number_images = test_number_images
        self.picture!.image_url = test_image_url
        self.picture!.post_picture = test_post_picture
        self.picture!.filter_sum_value = filter_sum_value
        
        XCTAssertNotNil(self.picture!.title, "Error in getter or setter for title")
        XCTAssertNotNil(self.picture!.post_date, "Error in getter or setter for post_date")
        XCTAssertNotNil(self.picture!.number_images, "Error in getter or setter for number_images")
        XCTAssertNotNil(self.picture!.image_url, "Error in getter or setter for image_url")
        XCTAssertNotNil(self.picture!.post_picture, "Error in getter or setter for post_picture")
        XCTAssertNotNil(self.picture!.filter_sum_value, "Error in getter or setter for filter_sum_value")
        
    }
    
}

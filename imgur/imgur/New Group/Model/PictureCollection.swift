//
//  PictureCollection.swift
//  imgur
//
//  Created by Johan Hernandez on 4/19/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import Foundation

public class PictureCollection {
    
    //MARK: - Internal Properties
    internal var _pictures: [Picture] = []
    internal var _toggle_filter_is_on : Bool = false
    internal var _errors_json_data_type : Array<String> = [] //holds information related with errors when data type isn't compatible
    
    //MARK: - Public Properties
    
    ///Get the number of pictures in the array
    public var count: Int {
        return self._pictures.count
    }
    
    //MARK: - public methods
    public func createCollectionFromJsonArray(json_pictures : Array<Dictionary<String, AnyObject>>){
        for (index, json_picture) in json_pictures.enumerated() {
            let picture = Picture()
            var include_in_list = true
            
            //Add image url and number of images
            if  let images = json_picture["images"] as? Array<Dictionary<String, AnyObject>>,
                images.count > 0 {
                //try to get first image from list or main image from post
                let first_image = images.first
                if let link_first_image = first_image!["link"] as? String {
                    picture.image_url = link_first_image
                    picture.number_images = Int16(images.count)
                }
            }
            else if let link = json_picture["link"] as? String{
                picture.image_url = link
                picture.number_images = 1
            }
            else {
                self._errors_json_data_type.append("Error adding image for element \(index)")
                include_in_list = false
            }
            
            //Add title
            if let title = json_picture["title"] as? String {
                picture.title = title.firstUppercased
            }
            else {
                self._errors_json_data_type.append("Error adding title for element \(index)")
                include_in_list = false
            }
            
            //Add date of post
            if let datetime = json_picture["datetime"] as? Double {
                picture.post_date = NSDate(timeIntervalSince1970: datetime)
            }
            else {
                self._errors_json_data_type.append("Error adding datetime for element \(index)")
                include_in_list = false
            }
            
            //If toggle is enabled, the app should only display results where the sum of “points”, “score” and “topic_id” adds up to an even number
            var points : Int = 0
            var score : Int = 0
            var topic_id : Int = 0
            if let json_points = json_picture["points"] as? Int {
                points = json_points
            }
            if let json_score = json_picture["score"] as? Int {
                score = json_score
            }
            if let json_topic_id = json_picture["topic_id"] as? Int {
                topic_id = json_topic_id
            }
            let features_sum = points+score+topic_id
            picture.filter_sum_value = features_sum
            if self._toggle_filter_is_on == true && (features_sum % 2) != 0 {
                include_in_list = false
            }
            
            if include_in_list == true {
                self._pictures.append(picture)
            }
        }
    }
    
    public func getCollection() -> Array<Picture>{
        return self._pictures
    }
    
    public func clearCollection() {
        self._pictures.removeAll()
    }
    
    public func getElementAtIndex(index : Int)->Picture{
        return self._pictures[index]
    }
    
    public func getErrorsJsonDataType()-> Array<String>{
        return self._errors_json_data_type
    }
}

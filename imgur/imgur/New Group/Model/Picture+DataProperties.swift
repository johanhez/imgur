//
//  Picture+DataProperties.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import Foundation

extension Picture {
    @NSManaged public var title: String
    @NSManaged public var post_date: NSDate
    @NSManaged public var number_images: Int32
    @NSManaged public var image_url: String
}

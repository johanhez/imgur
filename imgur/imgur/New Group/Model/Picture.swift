//
//  Picture.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import Foundation
import UIKit

public class Picture:NSObject {
    
    public var title: String?
    public var post_date: NSDate?
    public var number_images: Int16?
    public var image_url: String?
    public var post_picture: UIImage?
    
    
    override init(){
        super.init()
    }
    
}

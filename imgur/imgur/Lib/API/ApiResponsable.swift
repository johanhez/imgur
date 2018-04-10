//
//  ApiResponsable.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import Foundation

protocol ApiResponsable{
    func sendApiRequestFinished(response_array : Dictionary<String, AnyObject>, function_name_to_response : String);
}


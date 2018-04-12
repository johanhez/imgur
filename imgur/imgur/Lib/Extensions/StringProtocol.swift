//
//  String.swift
//  imgur
//
//  Created by Johan Hernandez on 4/12/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

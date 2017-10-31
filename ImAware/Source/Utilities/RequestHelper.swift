//
//  RequestHelper.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 19/10/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation

enum HTTPMethods : String {
    case GET = "GET"
    case POST = "POST"
}

struct Server {
    var url : URL
    var httpMethod : HTTPMethods
    var headers : [String : String]?
}

//
//  Error.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 18/10/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation

enum LocationError : Error {
    case missingAuthorization
    case serviceNotAvailable
    case timeout
    case authorizationDenied
    case monitoringError
}

enum AvalabilityError : Error {
    case notCompatibleIosVersion
}

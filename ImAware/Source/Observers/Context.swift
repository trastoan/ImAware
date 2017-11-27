//
//  Context.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 11/09/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation

enum ContextType {
    case hardware
    case location
    case activity
}

protocol Context {
    var contextType: ContextType {get set}
}

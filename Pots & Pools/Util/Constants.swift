//
//  Constants.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/28/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import Foundation
struct Constants {
    static let TODO_DATABASE = "todo"
    static let TODO_ITEMS_COLLECTION = "items"
    static let USERS_ITEMS_COLLECTION = "users"
    
    // your Atlas service name. On creation, this defauls to mongodb-atlas
    static let ATLAS_SERVICE_NAME = "pools-mongodb-atlas"
    // your Stitch APP ID
    static let STITCH_APP_ID = "potsandpoolsstitch-bjsgz" // <- update this!
}

struct PoolImg {
    let progress: NSObject
    let name: String
}

//
//  TodoItem.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/28/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import UIKit
import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

// A todo item from a MongoDB document
struct UserItem: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email = "email"
        case password = "password"
        case firstName = "firstName"
        case lastName = "lastName"
        case balanceAtRisk = "balanceAtRisk"
        case availBalance = "availBalance"
        case numActivePools = "numActivePools"
        case numWins = "numWins"
        case funded = "funded"
    }
    
    let id: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let balanceAtRisk: Double
    let availBalance: Double
    let numActivePools: Int
    let numWins: Int
    let funded: String

    
//    var checked: Bool {
//        didSet {
//            itemsCollection.updateOne(
//                filter: ["_id": id],
//                update: ["$set": [CodingKeys.checked.rawValue: checked] as Document],
//                options: nil) { _ in
//
//            }
//        }
 //   }
}


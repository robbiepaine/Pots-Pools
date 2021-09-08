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
struct TodoItem: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case ownerId = "owner_id"
        case amount = "amount"
        case funded = "funded"
        case unfunded = "unfunded"
        case participants = "participants"
        case allParticipants = "all participants"
        case paidParticipants = "paid participants"
        case unpaidParticipants = "unpaid participants"
        case fundingDate = "date funding"
        case createdDate = "date created"
        case task, checked
        case winner = "winner"
    }
    
    let id: ObjectId
    let ownerId: String
    let amount: Double
    let funded: Double
    let unfunded: Double
    let participants: Int
    let allParticipants: Array<String>
    let paidParticipants: Array<String>
    let unpaidParticipants: Array<String>
    let fundingDate: Date
    let createdDate: Date
    let task: String
    let winner: String

    
    var checked: Bool {
        didSet {
            itemsCollection.updateOne(
                filter: ["_id": id],
                update: ["$set": [CodingKeys.checked.rawValue: checked] as Document],
                options: nil) { _ in
                    
            }
        }
    }
}

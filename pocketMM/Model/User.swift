//
//  User.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import Firebase

enum Category{
//    case
}
struct User : Codable{
    let email : String
    let accessToken : String
    let itemId : String
    let transactions: [Transaction]
    let goals : [Goal]
    init(email: String, accessToken: String,
         itemId : String, transactions: [Transaction],
         goals: [Goal]){
        self.email = email
        self.accessToken = accessToken
        self.itemId = itemId
        self.transactions = transactions
        self.goals = goals
    }
    
}
struct Item {
    let accessToken: String
    let itemId : String
}

struct Transaction : Codable {
    let item_id: String
    let transaction_id : String
    let name : String
    let amount : Double
    let date : String
    let category : [String]?
    init(name: String, amount: Double, category: [String]?, item_id : String, transaction_id: String,
         date: String){
        self.name = name
        self.amount = amount
        self.category = category
        self.item_id  = item_id
        self.transaction_id = transaction_id
        self.date = date
    }
}

struct Goal :Codable {
    let name : String
    let monthlyAmount: Double
    let image: Data
}

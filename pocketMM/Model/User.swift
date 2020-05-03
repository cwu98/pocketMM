//
//  User.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import Firebase

struct User {
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
struct Transactions : Decodable{
    let transactions : [Transaction]
}
struct Transaction : Decodable {
    let transaction_id : String
    let amount : Double
    let date : String
    let category : [String]
    let item_id : String
    init(amount: Double, category: [String], item_id: String, transaction_id: String,
         date: String){
        self.amount = amount
        self.category = category
        self.transaction_id = transaction_id
        self.date = date
        self.item_id = item_id
    }
}

struct Goals: Decodable{
    let goals : [Goal]
}
//add current amount, price, saving,saving frequency,and a progress bar 
struct Goal :Decodable {
    let name : String
    let amount: Double
    let image: String
    init(name: String, amount: Double, image: String){
        self.name = name
        self.amount = amount
        self.image = image
    }
}

struct Bills: Decodable{
    let bills : [Bill]
}
struct Bill : Decodable {
    let name : String
    let due_date : String
    let frequency : String
    init(name: String, due_date : String, frequency: String){
        self.name = name
        self.due_date = due_date
        self.frequency = frequency
    }
}

struct Limit : Decodable {
    let limits : [String: Double]
}


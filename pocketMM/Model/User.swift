//
//  User.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import Firebase

struct User : Decodable{
    let email : String
    let access_token : String
    let item_id : String
    let transactions: [Transaction]
    let goals : [Goal]
    let reminders : [reminder]
    let limit : Limit
//    init(email: String, accessToken: String,
//         itemId : String, transactions: [Transaction],
//         goals: [Goal], reminders : [reminder]){
//        self.email = email
//        self.accessToken = accessToken
//        self.itemId = itemId
//        self.transactions = transactions
//        self.goals = goals
//    }
    
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

struct AccountsData : Decodable {
    let accounts : [AccountData]
}
struct AccountData : Decodable{
    let balances : BalanceData
}
struct BalanceData : Decodable{
    let current : Double
}


struct Goals: Decodable{
    let goals : [Goal]
}
//add [progress:current saved amount / goal item price, price], [save: # of money/frequency],[ a progress bar]
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

struct Reminders : Decodable{
    let reminders : [reminder]
}

struct reminder : Decodable{
    let title: String
    let date: Date
    let freq: String
    let alert: String
    let identifier: String
   
}
struct Limit : Decodable {
    let entertainment : Double
    let groceries : Double
    let shopping : Double
    let dining : Double
    let utilities : Double
    let rent : Double
    let goals : Double
    let miscellaneous : Double
}


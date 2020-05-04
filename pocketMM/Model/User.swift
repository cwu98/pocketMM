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
struct Transaction : Decodable, Hashable {
let transaction_id : String
let amount : Double
let date : String
let category : [String]
let category_id : Int?
let item_id : String
    
     func hash(into hasher: inout Hasher){
         hasher.combine(category_id)
     }
    init(amount: Double, category: [String], item_id: String, transaction_id: String,
     date: String){
    print("making transaction object")
    let category_id : Int
 
    if category.contains("Arts and Entertainment") || category.contains("Adult Entertainment") || category.contains("Entertainment"){
        category_id = 0
        
        }
    else if category.contains("Supermarkets and Groceries") || category.contains("Delis"){
        category_id = 1
    }
    else if category.contains("Shops") || category.contains("Clothing and Accessories"){
        category_id = 2
    }
    else if category.contains("Restaurants") || category.contains("Food and Drink") {
        category_id = 3
    }
        else if category.contains("Utilities"){
            category_id = 4
    }
        else if category.contains("Rent"){
            category_id = 5
    }
        else if category.contains("goals"){
            category_id = 6
    }
        else {
            category_id = 7
    }
    
    self.amount = amount
    self.category = category
    self.category_id = category_id
    print("category_id: \(category_id)")
    self.transaction_id = transaction_id
    self.date = date
    self.item_id = item_id
}
    func initCategory_id(category : [String]) -> Int{
        if category.contains("Arts and Entertainment") || category.contains("Adult Entertainment") || category.contains("Entertainment"){
//            category_id = 0
            return 0
            }
        else if category.contains("Supermarkets and Groceries") || category.contains("Delis"){
//            category_id = 1
            return 1
        }
        else if category.contains("Shops") || category.contains("Clothing and Accessories"){
//            category_id = 2
            return 2
        }
        else if category.contains("Restaurants") || category.contains("Food and Drink") {
//            category_id = 3
            return 3
        }
            else if category.contains("Utilities"){
//                category_id = 4
            return 4
        }
            else if category.contains("Rent"){
//                category_id = 5
            return 5
        }
            else if category.contains("goals"){
//                category_id = 6
            return 6
        }
            else {
//                category_id = 7
            return 7
        }
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
    let date: String
    let frequency: String
   // let alert: String
    let identifier: String
    
    init(title: String, date: String, frequency: String, identifier: String){
        self.title = title
        self.date = date
        self.frequency = frequency
        self.identifier = identifier
    }
   
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
    init(entertainment: Double, groceries: Double, shopping: Double,
               dining: Double, utilities: Double, rent: Double, goals: Double
        , miscellaneous: Double){
        self.entertainment = entertainment
        self.groceries = groceries
        self.shopping = shopping
        self.dining = dining
        self.utilities = utilities
        self.rent = rent
        self.goals = goals
        self.miscellaneous = miscellaneous
    }
}


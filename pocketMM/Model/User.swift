//
//  User.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation

enum Category{
//    case
}
struct User {
//    var userName : String {
//        get {
//            return "user_good"
//        }
//    }
//    var passWord : String {
//        get {
//            return "pass_good"
//        }
//    }
    let accessToken : String
    let itemId : String
//    var categories :
    var transactions : [Transaction]?
//    init(userName: String, passWord: String, accessToken: String,
//         itemId : Int, transactions : [Transaction]?){
//        self.
//    }
    init(accessToken: String,
         itemId : String, transactions : [Transaction]?){
        self.accessToken = accessToken
        self.itemId = itemId
        self.transactions = transactions
    }
    //date range
    //an array of transactions
    /*
     name
     amount
     date
     category
     */
    
    
}
struct Item {
    let accessToken: String
    let itemId : String
}

struct Transaction {
    let name : String
    let amount : Double
    let category : [String]?
    let category_id : String
    init(name: String, amount: Double, category: [String]?, category_id : String){
        self.name = name
        self.amount = amount
        self.category = category
        self.category_id = category_id
    }
}

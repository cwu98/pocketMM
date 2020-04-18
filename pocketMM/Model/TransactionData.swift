//
//  TransactionData.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
struct TransactionsData : Decodable {
    let transactions : [TransactionData]
    
}

struct TransactionData : Decodable {
    let name : String
//    let account_id : String
    let amount : Double
//    let iso_currency_code : String?
    
    let category : [String]
    let category_id : String
    
//    let date : String
//    let authorized_date : String
//
//    let location : LocationData
    
//    let pending : Bool
}
struct LocationData : Decodable {
    let address : String?
    let city : String?
    let region : String?
    let postal_code : String?
    let country : String?
    let lat : String?
    let lon : String?
    let store_number : String?
}

struct ItemData : Decodable {
    let access_token : String
    let item_id : String
}

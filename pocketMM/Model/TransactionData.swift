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
    let transaction_id : String
    let name : String
    let amount : Double
    let category : [String]
    let category_id : Int?
    let date : String
}

struct ItemData : Decodable {
    let access_token : String
    let item_id : String
}

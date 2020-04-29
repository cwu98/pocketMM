//
//  RetrieveDataFromFireBase.swift
//  pocketMM
//
//  Created by Ly Cao on 4/29/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import Firebase
func getTransactionFromRange(startDate: String, endDate: String)->[Transaction]?{
    var allTransactions : [Transaction]?
    
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd"
    

    if let start = dateFormatterGet.date(from: startDate),
    let end = dateFormatterGet.date(from: endDate){
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        print(dateFormatterPrint.string(from: start), dateFormatterPrint.string(from: end))
        let dateInterval = DateInterval(start: start, end: end)
        if let email = Auth.auth().currentUser?.email{
            db.collection(CONST.FSTORE.usersCollection).document(email).getDocument{
               (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                    return
                }
                allTransactions = []
                if let data = querySnapshot?.data(){
                    
                    let transactions = data[CONST.FSTORE.transactions] as! Array<Transaction>
                    print(transactions.description)
                    for transaction in transactions{
                        if let date = dateFormatterGet.date(from: transaction.date){
                            if(dateInterval.contains(date)){
                                allTransactions?.append(transaction)
                            }
                        }
                    }
                }
            }
        }
        
    } else {
       print("There was an error decoding the string")
        return allTransactions
    }
    return allTransactions
}

//
//  RetrieveDataFromFireBase.swift
//  pocketMM
//
//  Created by Ly Cao on 4/29/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import Firebase
var allTransactions : [Transaction] = []
func getTransactionFromRange(startDate: String, endDate: String)->[Transaction]{
     
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
                if let data = querySnapshot?.data(){
//                    print(data)
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)

                        let decodedData = try decoder.decode(Transactions.self, from: jsonData)
//                        print(decodedData)
                        for transaction in decodedData.transactions {
                            print(allTransactions.count)
                            allTransactions.append(
                                Transaction(
                                amount: transaction.amount,
                                category: transaction.category,
                                item_id : transaction.item_id,
                                transaction_id: transaction.transaction_id,
                                date: transaction.date)
                            )
                        }
                        print(allTransactions.count)
                    }
                    catch{
                        print("error from parsing transactions json : ", error)
                      
                    }
                    
                }
            }
        }
        
    } else {
       print("There was an error decoding the string")
        return allTransactions
    }
    print(allTransactions.count)
    return allTransactions
}

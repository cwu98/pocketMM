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
var allReminders : [reminder] = []
var limit: Limit?
var balance : Double = -1.0
var user : User?

protocol FirebaseTransactionDelegate{
    func didFinishGettingTransactions(transactions : [Transaction])
    func didFailToGetTransactions()
}

protocol FirebaseUserDelegate{
    func didFinishGettingUser(user : User)
    func didFailToGetUser()
}


struct FirebaseManager {
    var transactionsDelegate: FirebaseTransactionDelegate?
    var userDelegate: FirebaseUserDelegate?
    
    func getTransactionFromRange(startDate: String, endDate: String) {
         
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
                            
    //                        let str = jsonData.description
    //                        let data = str.data(using: String.Encoding.utf8)!
    //                        if let file = FileHandle(forWritingAtPath:"./transactions") {
    //                            file.write(data)
    //                        }
                            
                            let decodedData = try decoder.decode(Transactions.self, from: jsonData)
    //                        print("retrieved transactions")
    //                        print("transactions ", decodedData)
                            self.transactionsDelegate?.didFinishGettingTransactions(transactions : decodedData.transactions)
                            
                            for transaction in decodedData.transactions {
                                print(allTransactions.count)
                                if let date = dateFormatterGet.date(from: transaction.date){
                                    if(dateInterval.contains(date)) {
                                        allTransactions.append(
                                            Transaction(
                                            amount: transaction.amount,
                                            category: transaction.category,
                                            item_id : transaction.item_id,
                                            transaction_id: transaction.transaction_id,
                                            date: transaction.date)
                                        )
                                    }
                                }
                                
                                
                            }
                            print(allTransactions.count)
                        }
                        catch{
                            print("error from parsing transactions json : ", error)
                            self.transactionsDelegate?.didFailToGetTransactions()
                          
                        }
                        
                    }
                }
            }
            
        } else {
           print("There was an error decoding the string")
            self.transactionsDelegate?.didFailToGetTransactions()
//            return allTransactions
        }
        print(allTransactions.count)
//        return allTransactions
    }

    func getReminders(){
        if let email = Auth.auth().currentUser?.email{
            db.collection(CONST.FSTORE.usersCollection).document(email).getDocument{
               (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                    return
                }
                if let jsonData = querySnapshot?.data(){
                    let decoder = JSONDecoder()
                    do{
                        let data = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)

                        let decodedData = try decoder.decode(Reminders.self, from: data)
                        print("reminders ", decodedData)
                        for reminder in decodedData.reminders {
                            
                        }
                        print("all reminders ", allReminders)
                    }
                    catch{
                        print("error from parsing reminders json : ", error)
                      
                    }
                    
                }
            }
        }
    }
    func getLimit(){
        if let email = Auth.auth().currentUser?.email{
            db.collection(CONST.FSTORE.usersCollection).document(email).getDocument{
               (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                    return
                }
                if let jsonData = querySnapshot?.data(){
                    let decoder = JSONDecoder()
                    do{
                        let data = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)

                        let decodedData = try decoder.decode(Limit.self, from: data)
                        limit = decodedData
                        print("limits ", decodedData)
                    }
                    catch{
                        print("error from parsing limits json : ", error)
                      
                    }
                    
                }
            }
        }
    }

    func getUser(){
        if let email = Auth.auth().currentUser?.email{
            db.collection(CONST.FSTORE.usersCollection).document(email).getDocument{
               (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                    return
                }
                if let jsonData = querySnapshot?.data(){
                    let decoder = JSONDecoder()
                    do{
                        let data = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)

                        user = try decoder.decode(User.self, from: data)
                        self.userDelegate?.didFinishGettingUser(user : user!)
//                        PlaidAPIManager.getBalance(access_token: user!.access_token)
    //                    print(user!.transactions, balance, user!.limit, user!.reminders, user!.goals)
                        print("got user")
                        self.userDelegate?.didFinishGettingUser(user: user!)
                    }
                    catch{
                        print("error from parsing user json : ", error)
                        self.userDelegate?.didFailToGetUser()
                    }
                    
                }
            }
        }
        else{
            self.userDelegate?.didFailToGetUser()
        }
        
    }
    //get access to item_id via user
    func addTransaction(amount: Double, category: [String] , item_id : String
        , transaction_id : String, date: String){
        if let email = Auth.auth().currentUser?.email{
            let transaction = Transaction(
                                amount: amount,
                                category: category,
                                item_id : item_id,
                                transaction_id: transaction_id,
                                date: date)
            
            let docData : [String: Any] = [
                CONST.FSTORE.transaction_id : transaction.transaction_id,
                CONST.FSTORE.item_id : transaction.item_id,
                CONST.FSTORE.transaction_date : transaction.date,
                CONST.FSTORE.transaction_amount : transaction.amount,
                CONST.FSTORE.transaction_category : transaction.category,
                 CONST.FSTORE.transaction_category_id : transaction.category_id
                ]

            db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
                CONST.FSTORE.transactions : FieldValue.arrayUnion([docData])
            ])
        }
        else{
            print("failed to add Transaction")
        }
    }

}



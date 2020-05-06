//
//  PlaidAPIManager.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import WebKit
import Firebase


let db = Firestore.firestore()

protocol PlaidTransactionDelegate{
    func didFinishGettingTransactions(transactions : [Transaction])
    func didFailToGetTransactions()
}
protocol PlaidItemDelegate{
    func didFinishGettingItem(item_id : String, access_token : String)
//    func couldnGetTransaction()
}
protocol PlaidRefreshTransactionDelegate{
    func didFinishRedreshingTransactions(transactions : [Transaction])
//    func couldnGetTransaction()
}
protocol PlaidBalanceDelegate{
    func didFinishGettingBalance(accounts : AccountsData)
//    func couldnGetTransaction()
}

struct PlaidAPIManager{
    static let hostURL : String = "https://sandbox.plaid.com"
//    lazy var itemData : ItemData? = nil
    var transactionDelegate : PlaidTransactionDelegate?
    var itemDelegate : PlaidItemDelegate?
    var refreshTransactionDelegate : PlaidRefreshTransactionDelegate?
    var balanceDelegate : PlaidBalanceDelegate?
    
    func generateItemURL() -> String {
        let config = [
            "client_id": PLAID_CLIENT_ID,
            "secret": PLAID_SANDBOX_SECRET,
            "public_token":  PLAID_PUBLIC_KEY,
            "product": "[auth, transactions]",
            "selectAccount": "true",
            "clientName": "Test App",
            "isMobile": "true",
            "isWebview": "true",
            "webhook": "https://us-central1-pocketmm-d5886.cloudfunctions.net/webhook",
        ]

        var components = URLComponents()
        components.scheme = "https"
        components.host = PlaidAPIManager.hostURL
        components.path = "/item/public_token/exchange"
        components.queryItems = config.map { URLQueryItem(name: $0, value: $1) }
        return components.string!
    }
    
    func generateTransactionURL(_ accessToken : String) -> String {
        let config = [
            "client_id": PLAID_CLIENT_ID,
            "secret": PLAID_SANDBOX_SECRET,
            "access_token" : accessToken,
            "start_date": "2020-01-01",
            "end_date": "2020-04-18"
        ]

        var components = URLComponents()
        components.scheme = "https"
        components.host = PlaidAPIManager.hostURL
        components.path = "/transactions/get"
        components.queryItems = config.map { URLQueryItem(name: $0, value: $1) }
        return components.string!
    }

    
    func getItem(publicToken : String) {
    
//        let itemUrl = generateItemURL()
//        if let url = URL(string: itemUrl){
        
        if let url = URL(string: PlaidAPIManager.hostURL + "/item/public_token/exchange"){
            print(url)
            let session = URLSession(configuration: .default)
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
//            var request = URLRequest(url: url)
//            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request.httpMethod = "POST"
//            let webView = WKWebView()

            let parameters: [String: Any] = [
                "client_id": PLAID_CLIENT_ID,
                "secret": PLAID_SANDBOX_SECRET,
                "public_token":  publicToken
            ]
//            request.httpBody = parameters.percentEncoded()
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//                webView.load(request)
                let task = session.dataTask(with : request){
                    (data, response, error) in
                    if(error != nil){
                        print(error!)
//                        return nil
                        return
                    }
                    if let safeData = data {
//                        print("safe data from item", safeData)
                        do{
                            let jsonObject = try JSONSerialization.jsonObject(with: safeData)
                            print("item json ", jsonObject)
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        if let item = self.parseJsonItem(safeData){
                            self.itemDelegate?.didFinishGettingItem(item_id: item.item_id, access_token: item.access_token)
                        }
                    }
                }
                task.resume()
                
            } catch {
                print("error get item ", error.localizedDescription)
            }
        }
    
    }
    
    func getTransaction(accessToken: String, itemId : String, startDate: String, endDate: String)
    {
        print("get transaction " + accessToken + " " + itemId)
        if let url = URL(string: PlaidAPIManager.hostURL + "/transactions/get"){
            
            print(url)
            
            let session = URLSession(configuration: .default)
            
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
    
            //2020-01-01", "2020-04-18"
            let parameters: [String: Any] = [
                "client_id": PLAID_CLIENT_ID,
                "secret": PLAID_SANDBOX_SECRET,
                "access_token" : accessToken,
                "start_date": startDate,
                "end_date": endDate
            ]
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let task = session.dataTask(with : request){
                    (data, response, error) in
                    if(error != nil){
                        print(error!)
                        return
                    }
                    if let safeData = data {
                        do{
                            let jsonObject = try JSONSerialization.jsonObject(with: safeData)
                            print("transaction json ", jsonObject)
                        } catch {
                            print(error.localizedDescription)
                        }

                        if let parsedTransactions = self.parseTransactions(safeData, itemId: itemId) {
                            self.transactionDelegate?.didFinishGettingTransactions(transactions: parsedTransactions)
                        }
                    }
                }
                task.resume()
            } catch {
                print("error get transaction ", error.localizedDescription)
            }
        }
       
    }
    func parseJsonItem(_ data : Data) -> ItemData? {
            print("parsing Json Item")
            let decoder = JSONDecoder()
            do{
                let decodedData = try decoder.decode(ItemData.self, from: data)
                print("item is " , decodedData.access_token, decodedData.item_id)
                return decodedData
            }
            catch{
                print("error from parsing item json : ", error)
    //            delegate?.didFailToGetWeather(error)
                return nil
            }
        }
    func parseTransactions(_ data : Data, itemId: String)-> [Transaction]?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(TransactionsData.self, from: data)
            print("transaction is ", decodedData.transactions[0])
            var transactions : [Transaction] = []
            for transactionData in decodedData.transactions {
                let transaction = Transaction(
                                    amount: transactionData.amount,
                                    category: transactionData.category,
                                    item_id : itemId,
                                    transaction_id: transactionData.transaction_id,
                                    date: transactionData.date)
                transactions.append(transaction)
                
//                let docData : [String: Any] = [
//                    CONST.FSTORE.transaction_id : transaction.transaction_id,
//                    CONST.FSTORE.item_id : transaction.item_id,
//                    CONST.FSTORE.transaction_date : transaction.date,
//                    CONST.FSTORE.transaction_amount : transaction.amount,
//                    CONST.FSTORE.transaction_category : transaction.category,
//                    CONST.FSTORE.transaction_category_id : transaction.category_id
//                    ]
//                if let email = Auth.auth().currentUser?.email{
//                    db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
//                        CONST.FSTORE.transactions : FieldValue.arrayUnion([docData])
//                    ])
//                }
                

            }
            return transactions
        }
        catch{
            print("error from parsing transactions json : ", error)
            return nil
        }
    }

    func getBalance(access_token : String){
        if let url = URL(string: PlaidAPIManager.hostURL + "/accounts/balance/get"){
            let session = URLSession(configuration: .default)
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
                
            let parameters: [String: Any] = [
                "client_id": PLAID_CLIENT_ID,
                "secret": PLAID_SANDBOX_SECRET,
                "access_token":  access_token
            ]
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let task = session.dataTask(with: request) {
                    (data, response, error) in
                    if(error != nil){
                        print(error!)
                        return
                    }
                    if let safeData = data {
                        if let parsedAccountData = PlaidAPIManager.parseBalance(data: safeData){
                            self.balanceDelegate?.didFinishGettingBalance(accounts : parsedAccountData)
                        }
                    }
                }
                task.resume()
                
            } catch {
                print("error get balance from Plaid ", error.localizedDescription)
    //                return nil
            }
        }
        
        
    }
    static func parseBalance(data: Data) -> AccountsData?{
       do{
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(AccountsData.self, from: data)
            balance = decodedData.accounts[0].balances.current
             print("balance is ",balance)
            return decodedData
        }
        catch{
             print("error parsing balance from Plaid ", error.localizedDescription)
            return nil
        }
        
    }
    func refreshTransactions(access_token : String){
        if let url = URL(string: PlaidAPIManager.hostURL + "/transactions/refresh"){
            let session = URLSession(configuration: .default)
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
                
            let parameters: [String: Any] = [
                "client_id": PLAID_CLIENT_ID,
                "secret": PLAID_SANDBOX_SECRET,
                "access_token":  access_token
            ]
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let task = session.dataTask(with: request) {
                    (data, response, error) in
                    if(error != nil){
                        print(error!)
                        return
                    }
                    
                }
                task.resume()
                
            } catch {
                print("error get balance from Plaid ", error.localizedDescription)
    //                return nil
            }
        }
        
        
    }
    
    
    
   
}

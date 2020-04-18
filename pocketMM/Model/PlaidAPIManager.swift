//
//  PlaidAPIManager.swift
//  pocketMM
//
//  Created by Ly Cao on 4/18/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation
import WebKit


struct PlaidAPIManager{
    let hostURL : String = "https://sandbox.plaid.com"
//    lazy var itemData : ItemData? = nil
    func generateItemURL() -> String {
        let config = [
            "client_id": PLAID_CLIENT_ID,
            "secret": PLAID_SANDBOX_SECRET,
            "public_token":  PLAID_PUBLIC_KEY
        ]

        var components = URLComponents()
        components.scheme = "https"
        components.host = hostURL
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
        components.host = hostURL
        components.path = "/transactions/get"
        components.queryItems = config.map { URLQueryItem(name: $0, value: $1) }
        return components.string!
    }

    
    func getItem(publicToken : String) -> ItemData? {
    
//        let itemUrl = generateItemURL()
//        if let url = URL(string: itemUrl){
        
        var itemData : ItemData?
        if let url = URL(string: hostURL + "/item/public_token/exchange"){
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
//                            print("item is ", item.access_token,  item.item_id)
//                            Timer.scheduledTimer(withTimeInterval: 5, repeats: true){
//                                timer in
//                                let res = self.getTransaction(accessToken: item.access_token, itemId: item.item_id)
//                                if res {
//                                    timer.invalidates
//                                }
//                            }
                            itemData = item
//                            return item
                            
                        }
                    }
                }
                task.resume()
                
            } catch {
                print("error get item ", error.localizedDescription)
//                return nil
            }
        }
        return itemData
    }
    
    func getTransaction(accessToken: String, itemId : String) -> Bool? {
        print("get transaction " + accessToken + " " + itemId)
//        let transactionUrl = generateTransactionURL(accessToken)
        var res : Bool?
        if let url = URL(string: hostURL + "/transactions/get"){
//         if let url = URL(string: transactionUrl){
            
            print(url)
            
            let session = URLSession(configuration: .default)
            
            var request : URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //            "client_id": String,
            //            "secret": String,
            //            "access_token": String,
            //            "start_date": "2018-01-01",
            //            "end_date": "2018-02-01",
            //            "options": {
            //              "count": 250,
            //              "offset": 100
            //            }
            let parameters: [String: Any] = [
                "client_id": PLAID_CLIENT_ID,
                "secret": PLAID_SANDBOX_SECRET,
                "access_token" : accessToken,
                "start_date": "2020-01-01",
                "end_date": "2020-04-18"
            ]
//            request.httpBody = parameters.percentEncoded()
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//                webView.load(request)
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
                        
                        if self.parseJsonUser(safeData, accessToken, itemId) != nil {
    //                        self.delegate?.didFinishRequest(weather: weatherModel)
                            res = true
                        }
                    }
                }
                task.resume()
            } catch {
                print("error get transaction ", error.localizedDescription)
            }
        }
        return res
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
    func parseJsonUser(_ data : Data, _ acessToken: String,
        _ itemId : String) -> User? {
        print("parsing Json User")
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(TransactionsData.self, from: data)
            print("transaction is ", decodedData.transactions[0])
            var transactions : [Transaction] = []
            for transactionData in decodedData.transactions {
                transactions.append(Transaction(name: transactionData.name,
                                                amount: transactionData.amount,
                                                category: transactionData.category,
                                                category_id: transactionData.category_id))
            }
            let user = User(accessToken: acessToken, itemId : itemId, transactions: transactions)
            return user
        }
        catch{
            print("error from parsing user json : ", error)
//            delegate?.didFailToGetWeather(error)
            return nil
        }
    }
    
    
    
   
}

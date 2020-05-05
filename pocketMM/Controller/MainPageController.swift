//
//  MainPageController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase

class MainPageController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
  
    
    
    var accountNames: [String] = []
    var balances: [Double] = []
    @IBOutlet weak var textview: UITextView!
    
    @IBOutlet weak var datetextview: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(tableView: UITableViewDelegate, numberOfRowsInSection section: Int) -> Int {
//        return accountNames.count
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return accountNames.count
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var formatted = String(format: "$%.02f", balances[indexPath.row])
        cell.textLabel?.text = accountNames[indexPath.row] + ":      " + formatted
        if let email = Auth.auth().currentUser?.email {
            cell.textLabel!.text  = email + ":      " + "\(balance)"
        }
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        accountNames = ["Plaid Checking", "Plaid Credit Card", "Plaid Money Market"]
        balances = [3010.10, 501.00, 1100.00]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.datetextview.layer.cornerRadius = 25
        //self.view.bringSubviewToFront(textview);
        //view.sendSubviewToBack(imageView);
        title = "💰Home"
       print("in main page controller")
        navigationItem.hidesBackButton = true
        
//        loadTransactions()
        let today = Date()
        var startComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)
        startComponent.month = 1
        startComponent.day = 1
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let end = dateFormatterGet.string(from: today)
        print(end)
        datetextview.text = end
    //        if let startDate = Calendar.current.date(bySetting: .month, value: 1 , of: today){
         if let startDate = Calendar.current.date(from: startComponent){
           
            let start = dateFormatterGet.string(from: startDate)
            print("date", start, end)
            let plaidAPIManager : PlaidAPIManager = PlaidAPIManager()
            if let currentUser = user {
                PlaidAPIManager.refreshTransactions(access_token: currentUser.access_token)
                plaidAPIManager.getTransaction(accessToken: currentUser.access_token, itemId: currentUser.item_id, startDate: start, endDate: end)
                getTransactionFromRange(startDate: start, endDate: end)
                
            }
           
            
        }
        print("loading transactions")
    }

    

    
    
    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
}


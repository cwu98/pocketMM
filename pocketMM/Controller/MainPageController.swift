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
    var balanceAccounts : [AccountData] = []
    
    var plaidAPIManager = PlaidAPIManager()
    var firebaseManager = FirebaseManager()
    
    @IBOutlet weak var textview: UITextView!
    
    @IBOutlet weak var datetextview: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var refresher : UIRefreshControl!
    
    func tableView(tableView: UITableViewDelegate, numberOfRowsInSection section: Int) -> Int {
//        return accountNames.count
//        return 1
        print("number of cells in Main Page Controller", balanceAccounts.count)
        return balanceAccounts.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return accountNames.count
//        return 1
        return balanceAccounts.count
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let formatted = String(format: "$%.02f", balanceAccounts[indexPath.row].balances.current)
        cell.textLabel!.text  = balanceAccounts[indexPath.row].name + ": "
        cell.detailTextLabel?.text = formatted
         cell.contentView.backgroundColor = #colorLiteral(red: 0.8920666575, green: 0.9419104457, blue: 0.98284477, alpha: 0.8003264127)
               cell.contentView.layer.cornerRadius = 10
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        accountNames = ["Plaid Checking", "Plaid Credit Card", "Plaid Money Market"]
        balances = [3010.10, 501.00, 1100.00]
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd, yyyy"
        let date = dateFormatterGet.string(from: Date())
        datetextview.text = date
        datetextview.isEditable = false
        plaidAPIManager.refreshTransactionDelegate = self
        plaidAPIManager.balanceDelegate = self
        
        if let currentUser = user {
            plaidAPIManager.refreshTransactions(access_token: currentUser.access_token)
//            plaidAPIManager.getBalance(access_token: currentUser.access_token)
        }
        plaidAPIManager.transactionDelegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.layer.cornerRadius = 15
        self.datetextview.layer.cornerRadius = 25
        //self.view.bringSubviewToFront(textview);
        //view.sendSubviewToBack(imageView);
        title = "💰Home"
       print("in main page controller")
        navigationItem.hidesBackButton = true

        print("loading transactions")
        
        
        refresher = UIRefreshControl()
       refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
       refresher.addTarget(self,  action: #selector(MainPageController.populate), for: .valueChanged)
       
       tableView.addSubview(refresher)

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
extension MainPageController{
    
    @objc func populate(){
        if let currentUser = user {
            
            
            if(balanceAccounts.count == 0){
                plaidAPIManager.getBalance(access_token: currentUser.access_token)
            }
            else{
                self.refresher.endRefreshing()
                self.tableView.reloadData()
            }
            plaidAPIManager.refreshTransactions(access_token: currentUser.access_token)
        }
    }
    
}
extension MainPageController : PlaidRefreshTransactionDelegate{
    func didFinishRefreshingTransactions(transactions: [Transaction]) {
        
        let today = Date()
        var startComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)
        startComponent.month = 1
        startComponent.day = 1
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let end = dateFormatterGet.string(from: today)
        print(end)
        datetextview.text = end
         if let startDate = Calendar.current.date(from: startComponent){
           
            let start = dateFormatterGet.string(from: startDate)
            print("date", start, end)
            let plaidAPIManager : PlaidAPIManager = PlaidAPIManager()
            if let currentUser = user {
                plaidAPIManager.getTransaction(accessToken: currentUser.access_token, itemId: currentUser.item_id, startDate: start, endDate: end)
//                    getTransactionFromRange(startDate: start, endDate: end)
            }
           
            
        }
    }
    
    
}
extension MainPageController : PlaidTransactionDelegate{
    func didFinishGettingTransactions(transactions: [Transaction]) {
        for transaction in transactions {
            firebaseManager.addTransaction(amount: transaction.amount, category: transaction.category, item_id : transaction.item_id
                , transaction_id : transaction.transaction_id, date: transaction.date)
        }
        
    }
    
    func didFailToGetTransactions() {
        print("No new transactions")
    }
    
}
extension MainPageController : PlaidBalanceDelegate{
    func didFailToGetBalance() {
        self.refresher.endRefreshing()
        self.tableView.reloadData()
        print("failed to get balance from Main Page Controller")
    }
    
    func didFinishGettingBalance(accounts: AccountsData) {
        
        //user get here
        balanceAccounts = accounts.accounts
        print("got balance from Main Page Controller", balanceAccounts.count)
        DispatchQueue.main.async {
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        }
        
        
        //number of accounts =
    }
    
    
}


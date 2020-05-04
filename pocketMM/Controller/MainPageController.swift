//
//  MainPageController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase

class MainPageController: UIViewController {
    
    
    @IBOutlet weak var textview: UITextView!
    
   
   
    
    @IBOutlet weak var datetextview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

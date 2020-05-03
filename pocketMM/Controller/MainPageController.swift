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
    
   
    @IBOutlet weak var topview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topview.layer.cornerRadius = 40;
        //self.view.bringSubviewToFront(textview);
        //view.sendSubviewToBack(imageView);
        title = "💰Home"
       print("in main page controller")
        navigationItem.hidesBackButton = true
        let today = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let end = dateFormatterGet.string(from: today)
        print(end)
        if let startDate = Calendar.current.date(bySetting: .month, value: 1 , of: today){
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
        print("retrieved transactions")
        print(allTransactions)
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

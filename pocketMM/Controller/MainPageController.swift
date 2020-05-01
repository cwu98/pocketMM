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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Home"
       print("in main page controller")
        navigationItem.hidesBackButton = true
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Main",style: .plain, target: nil, action: nil)
        getTransactionFromRange(startDate: "2020-01-01", endDate: "2020-01-26")
        print("loading transactions")
        print("retrieved transactions")
//        print(allTransactions.count)
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

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
<<<<<<< HEAD
    
    @IBOutlet weak var summaryButton: UIButton!
    var user : User?
=======
   
>>>>>>> 8d7bcc787c49d3382498d8898ced720c91d36a5d
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Home"
       
        navigationItem.hidesBackButton = true
<<<<<<< HEAD
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Main",style: .plain, target: nil, action: nil)
=======
        print("loading transactions")
        if let transactions = getTransactionFromRange(startDate: "2020-01-01", endDate: "2020-04-26"){
            print("retrieved transactions")
            print(transactions.description)
        }
>>>>>>> 8d7bcc787c49d3382498d8898ced720c91d36a5d
    }

    
    //segue to summary page
    @IBAction func summaryButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "summarySegue", sender: nil)
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

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
        
        loadTransactions()
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

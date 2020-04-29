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
    
    @IBOutlet weak var summaryButton: UIButton!
    var user : User?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Home"
       
        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Main",style: .plain, target: nil, action: nil)
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

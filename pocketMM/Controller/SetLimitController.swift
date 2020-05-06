//
//  SetLimitController.swift
//  pocketMM
//
//  Created by Ly Cao on 5/1/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase

class SetLimitController: UIViewController {
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var limitTextField: UITextField!
    var firebaseManager = FirebaseManager()
    override func viewDidLoad() {
        super.viewDidLoad()
       title  = "Set Limit"
        errorTextView.isHidden = true
        firebaseManager.userDelegate = self
    }

    @IBAction func setLimitPressed(_ sender: Any) {
        if let category = categoryTextField.text, let limitPerMonth = limitTextField.text,
            let email = Auth.auth().currentUser?.email{
           
            db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
                "\(CONST.FSTORE.limit).\(category)" : Double(limitPerMonth)
            ])
            firebaseManager.getUser()
            let alert = UIAlertController(title: "Set Limit", message: "Successfully to set limit of \(limitTextField.text!) for category \(categoryTextField.text!)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                           alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Set Limit", message: "Failed to set limit for category \(categoryTextField.text!)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                           alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension SetLimitController : FirebaseUserDelegate{
    func didFinishGettingUser(user: User) {
        print("updated user after saving new limit")
    }
    
    func didFailToGetUser() {
        //
    }
    
    
}

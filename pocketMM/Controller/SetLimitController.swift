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
    override func viewDidLoad() {
        super.viewDidLoad()
       title  = "Set Limit"
        errorTextView.isHidden = true
    }

    @IBAction func setLimitPressed(_ sender: Any) {
        if let category = categoryTextField.text, let limitPerMonth = limitTextField.text,
            let email = Auth.auth().currentUser?.email{
           
            db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
                "\(CONST.FSTORE.limit).\(category)" : Double(limitPerMonth)
            ])
            errorTextView.isHidden = false
        }
        else{
            errorTextView.isHidden = true
            errorTextView.text = "Failed to set bill"
        }
    }
}

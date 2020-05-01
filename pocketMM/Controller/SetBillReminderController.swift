//
//  SetBillReminderController.swift
//  pocketMM
//
//  Created by Ly Cao on 5/1/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase
class SetBillReminderController: UIViewController {
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Bill"
        errorTextView.isHidden = false
    }
    
    @IBAction func setBillPressed(_ sender: Any) {
        if let name = nameTextField.text, let due_date = dueDateTextField.text, let frequency = frequencyTextField.text,
            let email = Auth.auth().currentUser?.email{
            let docData : [String: Any] = [
                CONST.FSTORE.bill_name : name,
                CONST.FSTORE.bill_due_date : due_date,
                CONST.FSTORE.bill_frequency : frequency
                ]

            db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
                CONST.FSTORE.bills : FieldValue.arrayUnion([docData])
            ])
            errorTextView.isHidden = false
        }
        else{
            errorTextView.isHidden = true
            errorTextView.text = "Failed to set bill"
        }
    }
    
}

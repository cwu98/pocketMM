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
    
    
    
}

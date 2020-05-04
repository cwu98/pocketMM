//
//  NewSpendingController.swift
//  pocketMM
//
//  Created by 胡诗梵 on 5/3/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase


class NewSpendingController: UIViewController {

    @IBOutlet weak var nameTextField: UITextView!
    @IBOutlet weak var amountTextField: UITextView!
    var category : String?
    @IBOutlet weak var datetextview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.datetextview.layer.cornerRadius = 25 
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func categorySelected(_ sender: UIButton) {
        if let cat = sender.titleLabel?.text {
           category = cat
        }
        
    }
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if let _ = nameTextField.text, let amount = Double(amountTextField.text), let cat = category,let currentUser = user {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            let date = dateFormatterGet.string(from: Date())
            addTransaction(amount: amount, category: [cat] , item_id : currentUser.item_id
            , transaction_id : NSUUID().uuidString, date: date)
            let alert = UIAlertController(title: "Add New Spending", message: "Successfully added new spending", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Add New Spending", message: "Failed to add spending", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
    }
}
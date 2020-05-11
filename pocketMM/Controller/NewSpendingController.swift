//
//  NewSpendingController.swift
//  pocketMM
//
//  Created by shifan on 5/3/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase


class NewSpendingController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    var category : String?
    @IBOutlet weak var datetextview: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet var activeButton: [UIButton]!
    
    var firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.datetextview.layer.cornerRadius = 25
        self.saveButton.layer.cornerRadius = 15
        
       let dateFormatterGet = DateFormatter()
       dateFormatterGet.dateFormat = "MMM dd, yyyy"
       let date = dateFormatterGet.string(from: Date())
        datetextview.text = date
        datetextview.isEditable = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        activeButton.forEach({ $0.backgroundColor = nil})
        sender.backgroundColor =  #colorLiteral(red: 0.9839375615, green: 0.8418782353, blue: 0.3591020703, alpha: 1)
        
        if let cat = sender.titleLabel?.text {
           category = cat
        }
        
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if let _ = nameTextField.text, let amount = amountTextField.text, let cat = category,let currentUser = user {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            let date = dateFormatterGet.string(from: Date())
            firebaseManager.addTransaction(amount: Double(amount) as! Double, category: [cat] , item_id : currentUser.item_id
            , transaction_id : NSUUID().uuidString, date: date)
            
            firebaseManager.getUser()
            
            let alert = UIAlertController(title: "Add New Spending", message: "Successfully added a new spending", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        }
        else{
            let alert = UIAlertController(title: "Add New Spending", message: "Failed to add the spending", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        }
        self.nameTextField.text = nil
        self.amountTextField.text = nil
        
    }
}

extension NewSpendingController : FirebaseUserDelegate{
    func didFinishGettingUser(user: User) {
        print("updated user after saving new spending")
    }
    
    func didFailToGetUser() {
        //
    }
    
    
}

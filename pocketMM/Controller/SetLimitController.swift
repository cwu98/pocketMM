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
    
    @IBOutlet weak var pickerView: UIPickerView!
    let categories = [
        CONST.Category.entertainment,
        CONST.Category.groceries,
        CONST.Category.shopping,
        CONST.Category.dining,
        CONST.Category.utilities,
        CONST.Category.rent,
        CONST.Category.goals,
        CONST.Category.miscellaneous
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       title  = "Set Limit"
        errorTextView.isHidden = true
        firebaseManager.userDelegate = self
        
        categoryTextField.textColor = .white
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }

    @IBAction func setLimitPressed(_ sender: Any) {
        if let category = categoryTextField.text, let limitPerMonth = limitTextField.text,
            let email = Auth.auth().currentUser?.email{
            if(category.trimmingCharacters(in: .whitespacesAndNewlines) == ""
                || limitPerMonth.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
                
                let alert = UIAlertController(title: "Set Limit", message: "All fields must be filled", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                               alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
//            let decimalCharacters = CharacterSet.decimalDigits
            let decimalCharacters = CharacterSet.letters

            let decimalRange = limitPerMonth.rangeOfCharacter(from: decimalCharacters)

            if decimalRange != nil{
                let alert = UIAlertController(title: "Set Limit", message: "Limit must be a number", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
            db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
                "\(CONST.FSTORE.limit).\(category)" : Double(limitPerMonth)!
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
extension SetLimitController: UIPickerViewDelegate{
    func pickerView(_: UIPickerView, didSelectRow: Int, inComponent: Int){
        categoryTextField.text = categories[didSelectRow]
//        print( categoryTextField.text)
    }
    func pickerView(_: UIPickerView, titleForRow: Int, forComponent: Int) -> String?{
        return categories[titleForRow]
    }
}

extension SetLimitController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categories.count
    }
    
    
}

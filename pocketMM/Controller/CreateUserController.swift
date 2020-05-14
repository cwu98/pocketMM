//
//  ViewController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/8/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import LinkKit
import WebKit
import Firebase

let PLAID_PUBLIC_KEY : String =  Bundle.main.object(forInfoDictionaryKey: "PLAID_PUBLIC_KEY") as! String
let PLAID_SANDBOX_SECRET : String =  Bundle.main.object(forInfoDictionaryKey: "PLAID_SANDBOX_SECRET") as! String
let PLAID_CLIENT_ID : String =  Bundle.main.object(forInfoDictionaryKey: "PLAID_CLIENT_ID") as! String

let access_token = "access-sandbox-7fe89844-5899-4597-b772-12bb86740dd4"
let item_id = "Zn1kvnglLbIjgx7Gkv4JS9nxaD7ww5igG1BZm"

class CreateUserController: UIViewController {
    var db: Firestore!
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var newAccount: UIButton!
    @IBOutlet weak var loginBA: UIButton!
   
    var plaidAPIManager : PlaidAPIManager = PlaidAPIManager()
    var firebaseManager  = FirebaseManager()
    var timer : Timer = Timer()
    var createAccountPressed = false
    var finishedGettingTransaction = false
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.isHidden = true
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.newAccount.layer.cornerRadius = 15
        self.loginBA.layer.cornerRadius = 15
        
        plaidAPIManager.itemDelegate = self
        plaidAPIManager.transactionDelegate = self
        firebaseManager.userDelegate = self
        
        emailTextField.becomeFirstResponder()
        passwordTextField.becomeFirstResponder()
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }

    @IBAction func createAccountPressed(_ sender: UIButton) {
        self.createAccountPressed = true
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if(email.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
                    
                    let alert = UIAlertController(title: "Create Account", message: "Please provide an email", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                   alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let e = error{
                 let alert = UIAlertController(title: "Create Account", message: e.localizedDescription, preferredStyle: .alert)
                 let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                 alert.addAction(okAction)
                 self.present(alert, animated: true, completion: nil)
                    return
                }
                else{
                    self.errorTextView.isHidden = true
                    let docData : [String: Any] = [
                            CONST.FSTORE.userEmail : email,
                            CONST.FSTORE.userAcessToken : access_token,
                            CONST.FSTORE.item_id : item_id,
                            CONST.FSTORE.transactions : [],
                            CONST.FSTORE.goals : [],
                            CONST.FSTORE.reminders : [],
                            CONST.FSTORE.limit : CONST.Category.limits
                            
                        ]
                    self.db!.collection(CONST.FSTORE.usersCollection).document(email).setData(docData) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                return
                            } else {
                                print("Document user successfully written!")
                            }
                    }
                    print("createAccountPressed", self.finishedGettingTransaction)
                    if(self.finishedGettingTransaction){
                        DispatchQueue.main.async {
                           self.performSegue(withIdentifier: CONST.registerSegue, sender: self)
                        }
                    }
                    
                }
            }
        }
        
    }
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        let linkConfiguration = PLKConfiguration(key: PLAID_PUBLIC_KEY, env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }

        present(linkViewController, animated: true)
    }
    
}

extension CreateUserController : PLKPlaidLinkViewDelegate, WKNavigationDelegate {
    
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        plaidAPIManager.getItem(publicToken: publicToken)
    }
    func handleError(_ error: Error, metadata: [String : Any]?) {
        let alert = UIAlertController(title: "Linking to Plaid Account", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
    }
    
    // With custom configuration
    
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        NSLog("Failed to link account!\nmetadata: \(metadata ?? [:])")
    }
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        NSLog("Link event: (event)\nmetadata: (metadata ?? [:])")
    }
    
}
extension CreateUserController : PlaidItemDelegate{
    func didFinishGettingItem(item_id: String, access_token: String) {
        print("didFinishGettingItem")
        let today = Date()
        //start of the year
        var startComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)
        startComponent.month = 1
        startComponent.day = 1
        let dateFormatterGet = DateFormatter()
       dateFormatterGet.dateFormat = "yyyy-MM-dd"
        //until today
        let end = dateFormatterGet.string(from: today)
   //        if let startDate = Calendar.current.date(bySetting: .month, value: 1 , of: today){
        if let startDate = Calendar.current.date(from: startComponent){
          
           let start = dateFormatterGet.string(from: startDate)
            plaidAPIManager.getTransaction(accessToken: access_token, itemId : item_id, startDate: start, endDate: end)
        }
    }
    
    
}
extension CreateUserController : PlaidTransactionDelegate{
    func didFinishGettingTransactions(transactions: [Transaction]) {
        finishedGettingTransaction = true
        print("didFinishGettingTransactions", createAccountPressed)
        if(createAccountPressed){
            for transaction in transactions {
                firebaseManager.addTransaction(amount: transaction.amount, category: transaction.category, item_id : transaction.item_id
                    , transaction_id : transaction.transaction_id, date: transaction.date)
            }
            firebaseManager.getUser()
        }
        
        DispatchQueue.main.async {
           self.performSegue(withIdentifier: CONST.registerSegue, sender: self)
        }
    }
    func didFailToGetTransactions(){
        print("didFailToGetTransactions", finishedGettingTransaction)
         finishedGettingTransaction = true
        if(createAccountPressed){
            DispatchQueue.main.async {
               self.performSegue(withIdentifier: CONST.registerSegue, sender: self)
            }
            
        }
    }
    
}
extension CreateUserController : FirebaseUserDelegate{
    func didFailToGetUser() {
        //
    }
    
    func didFinishGettingUser(user: User) {
        //
    }
    
}


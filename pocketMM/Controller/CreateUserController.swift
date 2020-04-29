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
    var itemData : ItemData?
    var plaidAPIManager : PlaidAPIManager = PlaidAPIManager()
    var timer : Timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.isHidden = true
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }

    @IBAction func createAccountPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    self.errorTextView.text = e.localizedDescription
                    self.errorTextView.isHidden = false
                }
                else{
                    self.errorTextView.isHidden = true
                    let docData = [
                            CONST.FSTORE.userEmail : email,
                            CONST.FSTORE.userAcessToken : access_token,
                            CONST.FSTORE.item_id : item_id,
                            CONST.FSTORE.transactions : "[]",
                            CONST.FSTORE.goals :"[]"
                        ]
                    self.db!.collection(CONST.FSTORE.usersCollection).document(email).setData(docData) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document user successfully written!")
                            }
                        }
                        
                    self.performSegue(withIdentifier: CONST.registerSegue, sender: self)
                    
//                        if self.itemData != nil {
//
//                        }
//                        else{
//                            print("itemData is funcking nil")
//                        }
                        
                    
                   
                    
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
//        if ([UIDevice userInterfaceIdiom] == .pad){
//            linkViewController.modalPresentationStyle = .formSheet;
//        }

        present(linkViewController, animated: true)
    }
    
}

extension CreateUserController : PLKPlaidLinkViewDelegate, WKNavigationDelegate {
    
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        print("Success " + publicToken)
        itemData = self.plaidAPIManager.getItem(publicToken: publicToken)
        if let item = itemData {
            print("fucking item is available")
        }
        addTransactionsToFirebaseDb()
        
//        getItemAndTransaction(publicToken)
        

    }
    
    func addTransactionsToFirebaseDb(){
        if let transactions = plaidAPIManager.getTransaction(accessToken: access_token, itemId: item_id, startDate: "2020-01-01", endDate: "2020-04-26"){
         for transaction in transactions{
            print(transaction)
//            let docData = [
//                CONST.FSTORE.transaction_id : transaction.transaction_id,
//                CONST.FSTORE.item_id : transaction.item_id,
//                CONST.FSTORE.transaction_date : transaction.date,
//                CONST.FSTORE.transaction_amount : String(format: "%f",transaction.amount),
//                CONST.FSTORE.transaction_category : transaction.category!.description
//            ]
//            db.collection(CONST.FSTORE.transactionsCollection).addDocument(data: docData){
//                (error) in
//                if let e = error{
//                    print("error uploading transactions to FireStore ", e)
//                }
//            }
         }
            
        }
        
    }
    
//    func getItemAndTransaction(_ publicToken: String, startDate: String, endDate: String){
//        var itemData : ItemData?
//        let radQueue = OperationQueue()
//        let operation1 = BlockOperation{
//            itemData = self.plaidAPIManager.getItem(publicToken: publicToken)
//        }
//        print("here")
//        let operation2 = BlockOperation{
////            self.plaidAPIManager.getTransaction(accessToken: "access-sandbox-446a6983-ede6-4e5d-abc4-a36a8e042e8e", itemId: "LWEPa9pW38HgAdn8kPDBF8qDmQVgM1cPKLMKx")
//            if let item = itemData{
//                print("getting trans item " + item.access_token + " " + item.item_id)
//                self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true){
//                     timer in
//                    if self.plaidAPIManager.getTransaction(accessToken: item.access_token, itemId: item.item_id, startDate: startDate,
//                        endDate: endDate) ?? true {
//                        self.timer.invalidate()
//                     }
//                 }
////                self.plaidAPIManager.getTransaction(accessToken: "access-sandbox-446a6983-ede6-4e5d-abc4-a36a8e042e8e", itemId: "LWEPa9pW38HgAdn8kPDBF8qDmQVgM1cPKLMKx")
////                self.plaidAPIManager.getTransaction(accessToken: item.access_token, itemId: item.item_id)
//            }
//
//        }
//
//        operation2.addDependency(operation1)
//        radQueue.addOperation(operation1)
//        radQueue.addOperation(operation2)
//    }
    func handleError(_ error: Error, metadata: [String : Any]?) {
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

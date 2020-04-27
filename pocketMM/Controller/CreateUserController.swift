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

class CreateUserController: UIViewController {
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var user : User?
    var plaidAPIManager : PlaidAPIManager = PlaidAPIManager()
    var timer : Timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.isHidden = true
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
                    self.performSegue(withIdentifier: Const.registerSegue, sender: self)
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
        print("Success " + publicToken)
     
        getItemAndTransaction(publicToken)
//        plaidAPIManager.getTransaction(accessToken: "access-sandbox-7fe89844-5899-4597-b772-12bb86740dd4", itemId: "Zn1kvnglLbIjgx7Gkv4JS9nxaD7ww5igG1BZm")

    }
    func getItemAndTransaction(_ publicToken: String){
        var itemData : ItemData?
        let radQueue = OperationQueue()
        let operation1 = BlockOperation{
            itemData = self.plaidAPIManager.getItem(publicToken: publicToken)
        }
        print("here")
        let operation2 = BlockOperation{
//            self.plaidAPIManager.getTransaction(accessToken: "access-sandbox-446a6983-ede6-4e5d-abc4-a36a8e042e8e", itemId: "LWEPa9pW38HgAdn8kPDBF8qDmQVgM1cPKLMKx")
            if let item = itemData{
                print("getting trans item " + item.access_token + " " + item.item_id)
                self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true){
                     timer in
                     if self.plaidAPIManager.getTransaction(accessToken: item.access_token, itemId: item.item_id) ?? true {
                        self.timer.invalidate()
                     }
                 }
//                self.plaidAPIManager.getTransaction(accessToken: "access-sandbox-446a6983-ede6-4e5d-abc4-a36a8e042e8e", itemId: "LWEPa9pW38HgAdn8kPDBF8qDmQVgM1cPKLMKx")
//                self.plaidAPIManager.getTransaction(accessToken: item.access_token, itemId: item.item_id)
            }
            
        }
        
        operation2.addDependency(operation1)
        radQueue.addOperation(operation1)
        radQueue.addOperation(operation2)
    }
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

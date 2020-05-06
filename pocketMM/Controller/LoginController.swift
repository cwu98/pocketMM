//
//  LoginController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    var firebaseManager = FirebaseManager()
    var plaidAPIManager = PlaidAPIManager()
    var balanceAccounts : AccountsData?
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var errorTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.isHidden = true
        firebaseManager.userDelegate = self
        plaidAPIManager.balanceDelegate = self
    }

    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {
                authResult, error in
                if let e = error{
//                    self.errorTextView.isHidden = false
//                    self.errorTextView.text = e.localizedDescription
                    let alert = UIAlertController(title: "Login", message: e.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print("logged in")
                    self.firebaseManager.getUser()
                }
              
            }
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextScene =  segue.destination as! MainPageController

        if (segue.identifier == CONST.loginSegue){
            if let balances = balanceAccounts{
                nextScene.balanceAccounts = balances.accounts
            }
            
        }
    }
}
extension LoginController : FirebaseUserDelegate{
    func didFailToGetUser() {
        print("did fail to get user in Log In Controller")
        DispatchQueue.main.async {
             
           self.performSegue(withIdentifier: CONST.loginSegue, sender: self)
        }
    }
    
    func didFinishGettingUser(user: User) {
//        DispatchQueue.main.async {
//           self.performSegue(withIdentifier: CONST.loginSegue, sender: self)
//        }
        print("did finish getting user in Log In Controller")
        self.plaidAPIManager.getBalance(access_token: user.access_token)
    }
    
}
extension LoginController: PlaidBalanceDelegate{
    func didFailToGetBalance() {
        print("did fail to get balance in Log In Controller")
        DispatchQueue.main.async {
             print("did fail balance in Log In Controller")
           self.performSegue(withIdentifier: CONST.loginSegue, sender: self)
        }
    }

    func didFinishGettingBalance(accounts: AccountsData) {
        print("did finish getting balance in Log In Controller")
        balanceAccounts = accounts
        DispatchQueue.main.async {
           self.performSegue(withIdentifier: CONST.loginSegue, sender: self)
        }

    }


}

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
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var errorTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.isHidden = true
//        firebaseManager.userDelegate = self
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
                    self.performSegue(withIdentifier: CONST.loginSegue, sender: self)
                }
              
            }
            
        }
        
    }
}

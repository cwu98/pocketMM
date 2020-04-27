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
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var user : User?
    
    @IBOutlet weak var errorTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.isHidden = true
    }

    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {
                authResult, error in
                if let e = error{
                    self.errorTextView.isHidden = false
                    self.errorTextView.text = e.localizedDescription
                }
                else{
                    self.errorTextView.isHidden = true
                    self.performSegue(withIdentifier: "login", sender: self)
                }
              
            }
            
        }
        
    }
}

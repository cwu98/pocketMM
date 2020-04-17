//
//  ViewController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/8/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import LinkKit

let PLAID_PUBLIC_KEY : String =  Bundle.main.object(forInfoDictionaryKey: "PLAID_PUBLIC_KEY") as! String

class ViewController: UIViewController {

    var public_token : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(PLAID_PUBLIC_KEY)
        
    }

    @IBAction func linkButtonPressed(_ sender: UIButton) {
        let linkConfiguration = PLKConfiguration(key: PLAID_PUBLIC_KEY, env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
//        let linkViewController = LinkViewController()
//        linkViewController.modalPresentationStyle = .formSheet;
        present(linkViewController, animated: true)
    }
    
}

extension ViewController : PLKPlaidLinkViewDelegate {
    
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        self.public_token = publicToken
        print("Success " + publicToken)
//        presentAlertViewWithTitle("Success", message: "token: \(publicToken)\nmetadata: \(metadata ?? [:])")
    }

    func handleError(_ error: Error, metadata: [String : Any]?) {
//        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
//        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
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
        NSLog("Failed to link account!\npublicToken: \(public_token ?? "")\nmetadata: \(metadata ?? [:])")
    }
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        NSLog("Link event: (event)\nmetadata: (metadata ?? [:])")
    }
    
}

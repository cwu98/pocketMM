//
//  NewSpendingController.swift
//  pocketMM
//
//  Created by 胡诗梵 on 5/3/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit

class NewSpendingController: UIViewController {

  
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

}

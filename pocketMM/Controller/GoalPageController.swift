//
//  GoalPageController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase


let headUrl = "https://firebasestorage.googleapis.com/v0/b/pocketmm-d5886.appspot.com/o/images%"
let tailUrl = ".png?alt=media&token=\(PLAID_PUBLIC_KEY)"
class GoalPageController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var goals : [Goal] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Goals"
        
        tableView.register(UINib(nibName: CONST.GoalCell, bundle: nil), forCellReuseIdentifier: CONST.cellReusableIdentifier)
        loadGoals()
        
    }
   
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
            let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
          
    }
}

extension GoalPageController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView count", goals.count)
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CONST.cellReusableIdentifier, for: indexPath) as! GoalCell
        cell.nameLabel.text = goals[indexPath.row].name
        cell.amountLabel.text = "\(goals[indexPath.row].amount)"
//        cell.imageView.image =
       
        let url = URL(string: goals[indexPath.row].image)
         let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url!){
            (data, response, error) in
            if let e = error{
                print(e.localizedDescription)
                return
            }
           
            DispatchQueue.main.async() {
                cell.goalImageView.image = UIImage(data: data!)
           }
        }
        task.resume()
        
        return cell
    }
    
    
}
extension GoalPageController{
    func loadGoals(){
        if let email = Auth.auth().currentUser?.email{
            db.collection(CONST.FSTORE.usersCollection).document(email).getDocument{
               (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                    return
                }
                if let data = querySnapshot?.data(){
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)

                        let decodedData = try decoder.decode(Goals.self, from: jsonData)
                        print("goals are", decodedData)
                        for goal in decodedData.goals {
                            self.goals.append(Goal(name: goal.name, amount: goal.amount, image: goal.image))
                        }
                        self.tableView.dataSource = self
                    }
                    catch{
                        print("error from parsing goals json : ", error)
                      
                    }
                    
                }
            }
        }
    }

}

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
    var refresher : UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Goals"
        self.tableView.layer.cornerRadius = 15
        
        tableView.register(UINib(nibName: CONST.goalTableViewCell, bundle: nil), forCellReuseIdentifier: CONST.cellReusableIdentifier)
//        loadGoals()
        print(goalTableViewCell.description())
        if let currentUser = user{
            goals = currentUser.goals
            tableView.dataSource = self
        }
        else{
            loadGoals()
        }
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self,  action: #selector(GoalPageController.populate), for: .valueChanged)
        
        tableView.addSubview(refresher)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CONST.cellReusableIdentifier, for: indexPath) as! goalTableViewCell
        
        print("at index ", indexPath.row, goals[indexPath.row])
        cell.name.text = goals[indexPath.row].name
        cell.progress.text = "\(goals[indexPath.row].amount)"
       
        if let url = URL(string: goals[indexPath.row].image){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){
                (data, response, error) in
                if let e = error{
                    print(e.localizedDescription)
                    return
                }
               
                DispatchQueue.main.async() {
                    cell.goalImage.image = UIImage(data: data!)
               }
            }
            task.resume()
        }
         
        cell.contentView.backgroundColor = #colorLiteral(red: 0.8920666575, green: 0.9419104457, blue: 0.98284477, alpha: 0.8003264127)
        cell.contentView.layer.cornerRadius = 10
        
        return cell
    }
    
    
}
extension GoalPageController{
    @objc func populate(){
        loadGoals()
    }
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
//                        print("goals are", decodedData)
//                        for goal in decodedData.goals {
//                            self.goals.append(Goal(name: goal.name, amount: goal.amount, image: goal.image))
//                        }
                        self.goals = decodedData.goals
                        self.tableView.dataSource = self
                        self.refresher.endRefreshing()
                        self.tableView.reloadData()
                    }
                    catch{
                        print("error from parsing goals json : ", error)
                      
                    }
                    
                }
            }
        }
    }

}

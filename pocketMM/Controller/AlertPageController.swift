//
//  AlertPageController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Foundation

class AlertPageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    var reminders = [reminder]()
    var notificationGranted = false
    var firebaseManager = FirebaseManager()
    var refresher : UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         title = "💰Reminders and Alerts"
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert,.sound]) {(granted, error) in
                self.notificationGranted = true
                if let error = error {
                    print("granted, but error in notif permissions:\(error.localizedDescription)")
                }
        }
     
        if let currentUser = user{
                reminders = currentUser.reminders
            }
            else{
                    reminders = loadReminders()
                }
              
        firebaseManager.userDelegate = self
        table.delegate = self
        table.dataSource = self
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self,  action: #selector(AlertPageController.populate), for: .valueChanged)
        
        table.addSubview(refresher)
        table.reloadData()
 
         
    }
    @objc func populate(){
        loadReminders()
    }
        func loadReminders() -> [reminder]{

            if let email = Auth.auth().currentUser?.email{
                                db.collection(CONST.FSTORE.usersCollection).document(email).getDocument{
                   (querySnapshot, error) in
                    if let e = error{
                        print(e.localizedDescription)
                        return
                    }
                    if let jsonData = querySnapshot?.data(){
                        let decoder = JSONDecoder()
                        do{
                            let data = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)

                             let decodedData = try decoder.decode(Reminders.self, from: data)
                            self.reminders = decodedData.reminders
                             for reminder in decodedData.reminders {
                                allReminders.append(reminder)
                            }
                            self.refresher.endRefreshing()
                            self.table.reloadData()
                            print("all reminders ", allReminders)
                        }
                        catch{
                            print("error from parsing reminders json : ", error)

                         }

                     }
                }

            }
            return allReminders
        }
 
        
    
    
        

     /* !!TO FIX !! */
        func convertToDate(date: String)-> Date? {
            let strDate = date
            
             let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ssZZZ"
            let xdate = dateFormatter.date(from: strDate)
            print("xdate: \(xdate)")

             return xdate!
        }
    
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
        //table.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let reminder = reminders[indexPath.row]
        cell.textLabel?.text = reminder.title
        print("\(reminder.title)", " ", "\(reminder.due_date)")
        let date = self.convertToDate(date: reminder.due_date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        cell.detailTextLabel?.text = "Due: " + formatter.string(from: date!)
        
        //make due date red if overdue
        if NSDate().earlierDate(self.convertToDate(date: reminder.due_date)!) == self.convertToDate(date: reminder.due_date) {
            cell.detailTextLabel?.textColor = UIColor.red
        }
        else if NSDate() as Date == self.convertToDate(date: reminder.due_date) {
            cell.detailTextLabel?.textColor = UIColor.red
        }
        else{
            cell.detailTextLabel?.textColor = UIColor.blue
          return cell
          
      }
        return cell
    }
    
    @IBAction func didTapAdd(){
        //show
        guard let addVC = storyboard?.instantiateViewController(withIdentifier: "add") as? AddReminderViewController else {
            return
        }
        
        addVC.title = "New Reminder"
        addVC.navigationItem.largeTitleDisplayMode = .never
        addVC.completion = {title, date, frequency, alert in
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(self, animated: true)
                let newReminder = reminder(title: title, due_date: "\(date)", frequency: frequency, identifier: "id_\(title)")
                print("new reminder created")
                self.reminders.append(newReminder)
                self.table.reloadData()
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = "pocketMM reminder"
                content.sound = .default
                
                //TODO ALERT PART
                
                let calendar = Calendar.current
                let targetDate = date
                
                var dateComponents = DateComponents()
                
                var repeats = false
                if frequency == "every month" {
                    dateComponents.day = calendar.component(.day, from: targetDate)
                    repeats = true
                }
                else if frequency == "every year" {
                    dateComponents.month = calendar.component(.month, from: targetDate)
                    repeats = true
                }
                else if frequency == "every week" {
                    dateComponents.weekday = calendar.component(.weekday, from: targetDate)
                    repeats = true
                }
                else if frequency == "never" {
                    dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
                    repeats = false
                }
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats )
                
                let request = UNNotificationRequest(identifier: "id_\(title)", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { (error) in
                    if let error = error {
                        print("error")
                    }
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ssZZZ"
                self.saveReminders(title: title, dueDate: formatter.string(from: date), frequency: frequency, identifier: "id_\(title)")
                print("notification added: \(request.identifier)")
                    
                }
            }
        
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    //save reminders to firebase
    func saveReminders(title: String, dueDate: String, frequency: String, identifier: String) {
        print("trying to save reminder to firebase")
        let title = title
        let due_date = dueDate
        let frequency = frequency
        let identifier = identifier
        let email = Auth.auth().currentUser?.email
        let docData : [String: Any] = [
                  CONST.FSTORE.reminder_title : title,
                  CONST.FSTORE.reminder_due_date : due_date,
                  CONST.FSTORE.reminder_frequency : frequency,
                  CONST.FSTORE.reminder_identifier : identifier
        ]

        db.collection(CONST.FSTORE.usersCollection).document(email!).updateData([
                  CONST.FSTORE.reminders : FieldValue.arrayUnion([docData])
              ])
        let alert = UIAlertController(title: "Save Reminders", message: "Successfully saved reminder", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
        
        firebaseManager.getUser()
      
    }
    
    func removeFromFirebase(title: String){
        if let email = Auth.auth().currentUser?.email{
            db.collection("reminders").document(email).updateData(["id_\(title)": FieldValue.delete(),
                ]){err in
                    if let err = err{
                        print("error deleting document: \(err)")
                    } else{
                        print("Document successfully updated")
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let toRemove = reminders.remove(at: indexPath.row)
            
            //TODO cancel local notification
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [toRemove.identifier])
            tableView.deleteRows(at: [indexPath], with: .fade)
            removeFromFirebase(title: toRemove.title)
        }
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


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }


  
}

extension AlertPageController : FirebaseUserDelegate{
    func didFinishGettingUser(user: User) {
        print("updated user after saving new reminder")
    }
    
    func didFailToGetUser() {
        //
    }
    
    
}
    
    



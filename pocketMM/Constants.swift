//
//  Constants.swift
//  pocketMM
//
//  Created by Ly Cao on 4/27/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import Foundation

struct CONST{
    static let registerSegue = "createAccount"
    static let loginSegue = "login"
    
    static let cellReusableIdentifier = "ReusableCell"
    static let GoalCell = "GoalCell"
    static let settingsCellIdentifer = "SettingsCell"
    static let reminderSeque = "reminderSegue"
    static let limitSeque = "limitSegue"
    
    static let balance = "balance"
    static let goalTableViewCell = "goalTableViewCell"
    
    struct FSTORE{
        static let usersCollection = "users"
        static let userEmail = "email"
        static let userAcessToken = "access_token"
        static let userItemId = "item_id"
        static let goals = "goals"
        static let goal_name = "name"
        static let goal_amount = "amount"
        static let goal_image = "image"
        
        static let limit = "limit"
        
        static let reminders = "reminders"
        static let reminder_title = "title"
        static let reminder_due_date = "due_date"
        static let reminder_frequency = "frequency"
        
        static let transactions = "transactions"
        static let item_id = "item_id"
         static let transaction_id = "transaction_id"
        static let transaction_name = "name"
        static let transaction_amount = "amount"
        static let transaction_date = "date"
        static let transaction_category = "category"
        static let transaction_category_id = "category_id"

        
    }
    
    struct Category{
        static let entertainment = "entertainment"
        static let groceries = "groceries"
        static let shopping = "shopping"
        static let dining = "dining"
        static let utilities = "utilities"
        static let rent = "rent"
        static let goals = "goals"
        static let miscellaneous = "miscellaneous"
        static let limits = [
            entertainment : -1.0,
            groceries : -1.0,
            shopping : -1.0,
            dining : -1.0,
            utilities : -1.0,
            rent : -1.0,
            goals : -1.0,
            miscellaneous : -1.0
        ]
    }
}

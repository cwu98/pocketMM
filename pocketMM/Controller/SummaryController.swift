//
//  SummaryController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//


import UIKit
import Firebase
import Charts
//table cell of bottom table view
struct tablecelldata {
    let cell : Int!
    let index : String!     //number + .
    let percent : String!   //number + %
    let name : String!
    let amount : String!    //$ + number
}

class SummaryController: UIViewController, UITextFieldDelegate {
  
    var plaidAPIManger = PlaidAPIManager()
    var firebaseManager = FirebaseManager()
    
    @IBOutlet weak var pieChart:PieChartView!
    @IBOutlet weak var monthLabel: UITextField!
    @IBOutlet weak var yearLabel: UILabel!
    
    var datePicker = MonthYearPickerView()

    var selectedMonth: String?
    var month: Int = 0
    var year: Int = 0
    let arrayOfMonths = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    let categories = ["Entertainment", "Groceries", "Shopping", "Dining", "Utilities", "Rent", "Goals", "Miscellaneous"]
    var monthSpending: Double?

    var transactionData = [Transaction]()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In summary controller")

        //        plaidAPIManger.transactionDelegate = self
        firebaseManager.transactionsDelegate = self
        
        if(user == nil){
            firebaseManager.userDelegate = self
            firebaseManager.getUser()
        }
        
        monthLabel.delegate = self
        datePicker.onDateSelected = { (month: Int, year: Int) in
            let string = String  (format: "%02d/%d",month, year)
            print(string)
        }
        
        
        //display current month and year
        let date = Date()
        print("curent date: \(date)")
        let calendar = Calendar.current
        month = calendar.component(.month, from: date)
        year = calendar.component(.year, from: date)
        monthLabel.text = arrayOfMonths[month-1]
        yearLabel.text = "\(year)"
 
        createDatePicker()
        transactionData = user?.transactions as! [Transaction]

        displayForSelectedMonth()
        
    }
    
    func createDatePicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        //assign toolbar
        monthLabel.inputAccessoryView = toolbar
        
        //assign date picker to text field
        monthLabel.inputView = datePicker

        
        
        
    }
    
    @objc func donePressed() {
        //format
       
        monthLabel.text = arrayOfMonths[datePicker.month-1]
        yearLabel.text = "\(datePicker.year)"
        month = datePicker.month
        year = datePicker.year
        displayForSelectedMonth()
        
        monthLabel.endEditing(true)
    }
    
    func getTransactionsByDateRange(startDate: Date, endDate: Date)  -> [Transaction]{
        var tempArr : [Transaction] = []
        print(startDate, " ", endDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for transaction in transactionData {
            var date = dateFormatter.date(from: transaction.date)
            if (startDate ... endDate).contains(date!){

                tempArr.append(transaction)
            }
        }
        print("transactions in this date range")
        for t in tempArr {
            print(t)
        }
        return tempArr
    }
    
    func displayForSelectedMonth(){
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.year = year
        let userCalendar = Calendar.current
        var startDate = userCalendar.date(from: dateComponents)
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        var endDate = userCalendar.date(byAdding: comps2, to: startDate!)
        var groupByCategory = [[Transaction]]()
         var totalSpendingByCategory = [Double]()
         var transactionsForMonth = [Transaction]()
        transactionsForMonth = getTransactionsByDateRange(startDate: startDate!, endDate: endDate!)
        groupByCategory = [ [], [], [], [], [], [], [], [] ]
        for item in transactionsForMonth {
             groupByCategory[item.category_id].append(item)
         }

         for list in groupByCategory {
             totalSpendingByCategory.append(list.reduce(0) { $0 + $1.amount})
         }
         
         totalSpendingByCategory[0] = 120.50 //dummy entertainment
         totalSpendingByCategory[5] = 1550.00 //dummy rent
         
         print(totalSpendingByCategory)
        monthSpending = totalSpendingByCategory.reduce(0){$0 + $1}
        updateChartData(totalSpendingByCategory: totalSpendingByCategory)
    }
    
    func updateChartData(totalSpendingByCategory : [Double]){
        pieChart.backgroundColor = .white
        var entries: [PieChartDataEntry] = []
        for i in 0..<totalSpendingByCategory.count {
            let dataEntry = PieChartDataEntry(value: totalSpendingByCategory[i], label: categories[i] )
            entries.append(dataEntry)
        }
        let chartDataSet = PieChartDataSet(entries: entries, label:"")
        
        let chartData = PieChartData(dataSet: chartDataSet)
       
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.zeroSymbol = ""
        
        chartData.setValueFormatter((DefaultValueFormatter(formatter: formatter)))
        let color1 = NSUIColor(hex: 0xC39BD3) //purple
        let color2 = NSUIColor(hex: 0xAED6F1) //blue
        let color3 = NSUIColor(hex: 0x76D7C4) //green
        let color4 = NSUIColor(hex: 0xF4D03F) //yellow
        let color5 = NSUIColor(hex: 0xF39C12) //orange
        let color6 = NSUIColor(hex: 0xEC7063) //red
        let color7 = NSUIColor(hex: 0xB2BABB) //gray
        let color8 = NSUIColor(hex: 0xFADBD8)   //pink
        
        
        chartDataSet.colors = [color1, color2, color3, color4, color5, color6, color7, color8]

        
        chartDataSet.drawIconsEnabled = false
        chartDataSet.sliceSpace = 3
        pieChart.data = chartData
        pieChart.chartDescription?.text = arrayOfMonths[month-1] //month to display
        pieChart.drawHoleEnabled = true
        pieChart.holeRadiusPercent = 0.3
        pieChart.transparentCircleRadiusPercent = 0.33
        pieChart.legend.enabled = true
        pieChart.rotationEnabled = false
        pieChart.drawEntryLabelsEnabled = false
        chartDataSet.valueTextColor = .blue
        pieChart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        chartDataSet.valueLineColor = .gray
       chartDataSet.valueLinePart1OffsetPercentage = 0.6
    chartDataSet.valueLinePart1Length = 0.6
              chartDataSet.valueLinePart2Length = 0.5
               chartDataSet.yValuePosition = .outsideSlice
        let l = pieChart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.xEntrySpace = 0
        l.yEntrySpace = 8
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.currencySymbol = "$"
        nf.numberStyle = .currency
        pieChart.centerText = "Total: " + nf.string(from: NSNumber(value: monthSpending!))!
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

extension SummaryController : FirebaseTransactionDelegate{
    func didFailToGetTransactions() {
        //
    }
    
    func didFinishGettingTransactions(transactions: [Transaction]) {
        //do your thing here
    }
    
    
}
extension SummaryController : FirebaseUserDelegate{
    func didFailToGetUser() {
        //
    }
    
    func didFinishGettingUser(user: User) {
        //user get here
    }
    
    
}



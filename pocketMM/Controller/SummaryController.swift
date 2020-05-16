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

class SummaryController: UIViewController, ChartViewDelegate, UITextFieldDelegate {
  
    var plaidAPIManger = PlaidAPIManager()
    var firebaseManager = FirebaseManager()
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var monthLabel: UITextField!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
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

        firebaseManager.transactionsDelegate = self
        
        if(user == nil){
            firebaseManager.userDelegate = self
            firebaseManager.getUser()
        }
        
        pieChart.delegate = self
        pieChart.noDataText = "There is no data for the month and year selected"
        monthLabel.delegate = self
        datePicker.onDateSelected = { (month: Int, year: Int) in
            let string = String  (format: "%02d/%d",month, year)
            //print(string)
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
        guard let transactionData = user?.transactions else{
            return
        }
        self.transactionData = transactionData

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
        guard let transactionData = user?.transactions else{
            return []
        }
        self.transactionData = transactionData
        for transaction in transactionData {
            let date = dateFormatter.date(from: transaction.date)
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
        let startDate = userCalendar.date(from: dateComponents)
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endDate = userCalendar.date(byAdding: comps2, to: startDate!)
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
         //default category label and progress bar for "Entertainment"
          let formatter = NumberFormatter()
          formatter.usesGroupingSeparator = true
          formatter.currencySymbol = "$"
          formatter.numberStyle = .currency
          formatter.locale = Locale.current
          categoryLabel.text = categories[0]
        totalLabel.text = formatter.string(from: NSNumber(value: totalSpendingByCategory[0]))
        var progress: Float
          if user?.limit.entertainment ?? -1.0 >= 0.0 {
            progressLabel.text = formatter.string(from: NSNumber(value: totalSpendingByCategory[0] ))! + " / " + formatter.string(from: NSNumber(value: user?.limit.entertainment ?? 0.0))!
            progress = Float(totalSpendingByCategory[0]/(user?.limit.entertainment)! ?? 1.0)
          }
         else{
          progressLabel.text = "Set budget limit in settings"
            progress = 0.0
          }
        progressBar.setProgress(progress, animated: false)


        monthSpending = totalSpendingByCategory.reduce(0){$0 + $1}
        updateChartData(totalSpendingByCategory: totalSpendingByCategory)
    }
    
    func updateChartData(totalSpendingByCategory : [Double]){
        var entries: [PieChartDataEntry] = []
        for i in 0..<totalSpendingByCategory.count {
            let dataEntry = PieChartDataEntry(value: totalSpendingByCategory[i], label: categories[i])
            dataEntry.x = Double(i)
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
        chartData.setValueFont(.systemFont(ofSize: 11, weight: .light))
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
        chartDataSet.valueTextColor = .blue
        chartDataSet.drawValuesEnabled = false
        /*
        chartDataSet.valueLineColor = .gray
        chartDataSet.valueLinePart1OffsetPercentage = 0.8
        chartDataSet.valueLinePart1Length = 0.2
        chartDataSet.valueLinePart2Length = 0.4
        chartDataSet.yValuePosition = .outsideSlice
        */
        
        pieChart.data = chartData
        pieChart.chartDescription?.text = arrayOfMonths[month-1] //month to display
        pieChart.drawHoleEnabled = true
        pieChart.holeRadiusPercent = 0.3
        pieChart.transparentCircleRadiusPercent = 0.33
        pieChart.legend.enabled = true
        pieChart.rotationEnabled = false
        pieChart.drawEntryLabelsEnabled = false
        pieChart.isUserInteractionEnabled = true
        pieChart.highlightPerTapEnabled = true
        pieChart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)

        let l = pieChart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.xEntrySpace = 0
        l.yEntrySpace = 8
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.currencySymbol = "$"
        nf.numberStyle = .currency
        pieChart.centerText = "Total: \n" + nf.string(from: NSNumber(value: monthSpending!))!

    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //print("index: \(entry.x) value: \(entry.y)\n")
        let index : Int = Int(entry.x)
        var limit: Double? = 0.0
        switch index {
        case 0:
            limit = user?.limit.entertainment
            break
        case 1:
            limit = user?.limit.groceries
            break
        case 2:
            limit = user?.limit.shopping
            break
        case 3:
            limit = user?.limit.dining
            break
        case 4:
            limit = user?.limit.utilities
            break
        case 5:
            limit = user?.limit.rent
            break
        case 6:
            limit = user?.limit.goals
            break
        case 7:
            limit = user?.limit.miscellaneous
        default:
            print("error")
        }
        let formatter = NumberFormatter()
         formatter.usesGroupingSeparator = true
         formatter.currencySymbol = "$"
         formatter.numberStyle = .currency
         formatter.locale = Locale.current
         categoryLabel.text = categories[index]
        totalLabel.text = formatter.string(from: NSNumber(value: entry.y))
        var progress: Float
         if limit ?? -1.0 >= 0.0 {
            progressLabel.text = formatter.string(from: NSNumber(value: entry.y))! + " / " + formatter.string(from: NSNumber(value: limit ?? 1.0))!
            progress = Float(entry.y/limit! ?? 1.0)

         }
        else{
         progressLabel.text = "Set budget limit in settings"
            progress = 0.0
         }
        progressBar.setProgress(progress, animated: false)

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



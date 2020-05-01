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

class SummaryController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pieChart:PieChartView!
    @IBOutlet weak var monthLabel: UITextField!
    @IBOutlet weak var yearLabel: UILabel!
    
    var selectedMonth: String?
    var user : User?
    var month: Int = 0
    var year: Int = 0
    let arrayOfMonths = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    //array of transaction data of type TransactionData
    var transactionData = [TransactionData]()
    
    //array to hold total spending per category... this is the data for pie chart
    var totalSpendingByCategory = [Double]()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //
        let datePicker = MonthYearPickerView()
        monthLabel.inputView = datePicker
        datePicker.onDateSelected = { (month: Int, year: Int) in
            let string = String  (format: "%03d/%d",month, year)
            NSLog(string)
        }
        
        //get current month and year
        let date = Date()
        let calendar = Calendar.current
        month = calendar.component(.month, from: date)
        year = calendar.component(.year, from: date)
        monthLabel.leftViewMode = UITextField.ViewMode.always
        monthLabel.leftViewMode = .always
        monthLabel.text = arrayOfMonths[month]
        //monthLabel.leftView = UIImageView(image: UIImage(named: "downArrow.png"))
        yearLabel.text = "\(year)"
        
        //get transaction data
        //transactionData =
        
        //group based on category into dict [category_id : [...list of TransactionData objects with this category_id ] ]
        var groupByCategory = Dictionary(grouping: transactionData, by: {$0.category} )

        for (categoryID, transaction) in groupByCategory{
            var total = transaction.reduce(0) {  $0 + $1.amount} //sum all amount from transactions in each category
           // totalSpendingByCategory.insert(total, at: categoryID)
        }

        


        updateChardData()
        
        
    }
    
    func updateChardData(){
        
        var entries: [PieChartDataEntry] = []
        for i in 0..<totalSpendingByCategory.count {
            let dataEntry = PieChartDataEntry(value: totalSpendingByCategory[i], label: "Category \(i)" )
            entries.append(dataEntry)
        }
        let chartDataSet = PieChartDataSet(entries: entries, label:"Categories")
        
        let chartData = PieChartData(dataSet: chartDataSet)
        //assign colors??
        //let colors = [UIColor , UIColor, ...]
        //chartDataSet.colors = colors as! [NSUIColor]
       
        
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
        chartDataSet.sliceSpace = 2
        pieChart.data = chartData
        pieChart.chartDescription?.text = "January" //month to display
        pieChart.drawHoleEnabled = true
        pieChart.holeRadiusPercent = 30
        pieChart.legend.enabled = true
        pieChart.rotationEnabled = false
        pieChart.entryLabelColor = .white
        pieChart.entryLabelFont = .systemFont(ofSize: 14, weight:.light)
        
        let l = pieChart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.xEntrySpace = 0
        l.yEntrySpace = 8
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

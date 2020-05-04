//
//  AddViewController.swift
//  pocketMM
//
//  Created by user167006 on 5/1/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet var titleField: UITextField!
    var datePicker = UIDatePicker()
    @IBOutlet var dueDateField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var frequencyField: UITextField!
    @IBOutlet var alertMeField: UITextField!
    
    var frequencyPicker = UIPickerView()
    var alertPicker = UIPickerView()
    
    public var completion: ((String, Date, String, String) -> Void)?
    
    let freqArr = ["every month", "every week", "every year", "never"]
    let alertArr = ["1 day", "2 days", "3 days", "4 days", "5 days", "6 days", "1 week", "2 weeks"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        titleField.delegate  = self
        frequencyField.delegate = self
        alertMeField.delegate = self
        //checkFields()
        frequencyPicker.delegate = self
        frequencyPicker.dataSource = self
        frequencyField.textAlignment = .center
        alertPicker.delegate = self
        alertPicker.dataSource = self
        alertMeField.textAlignment = .center
        createDatePicker()
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 30
        let maxDate = calendar.date(byAdding: comps, to: Date())
        datePicker.maximumDate = maxDate
        comps.year = 0
        datePicker.minimumDate = calendar.date(byAdding: comps, to: Date())
        datePicker.locale = NSLocale.current
        dueDateField.inputView = datePicker

        frequencyField.inputView = frequencyPicker
        alertMeField.inputView = alertPicker
        
        frequencyPicker.tag = 0
        alertPicker.tag = 1
        
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0 {
            return freqArr.count
        }
        else if pickerView.tag == 1 {
            return alertArr.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return freqArr[row]
        }
        else if pickerView.tag == 1 {
            return alertArr[row]
            
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            frequencyField.text = "Repeats: " + freqArr[row]
            frequencyField.resignFirstResponder()
        }
        else if pickerView.tag == 1 {
            alertMeField.text = alertArr[row] + " before due date"
            alertMeField.resignFirstResponder()
        }
    }
    
    func checkFields(){
        //disable save button if field is empty
        if !titleField.hasText  || !dueDateField.hasText || !frequencyField.hasText || !alertMeField.hasText {
            saveButton.isEnabled = false
        }
        else{
            saveButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapSaveButton(){
        if let titleText = titleField.text,
            let freqText = frequencyField.text,
            let alertMeText = alertMeField.text {
            
            completion?(titleText, datePicker.date, freqText, alertMeText)
        }
        print("save button tapped")
    }
    
    
    func createDatePicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        //assign toolbar
        dueDateField.inputAccessoryView = toolbar
   
        //assign date picker to text field
        dueDateField.inputView = datePicker
        
        //date picker mode
        //datePicker.datePickerMode = .date
        
        self.view.endEditing(true)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
    
    @objc func donePressed() {
        //format
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        dueDateField.text = formatter.string(from: datePicker.date)
    }
    

}

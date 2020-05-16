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
    
    var frequencyPicker = UIPickerView()
    
    public var completion: ((String, Date, String) -> Void)?
    
    let freqArr = ["", "every month", "every week", "every year"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        titleField.delegate  = self
        frequencyField.delegate = self
        //checkFields()
        frequencyPicker.delegate = self
        frequencyPicker.dataSource = self
        frequencyField.textAlignment = .center
        createFrequencyPicker()
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


        
        frequencyPicker.tag = 0
        
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0 {
            return freqArr.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return freqArr[row]
        }
   
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            frequencyField.text = "Repeats: " + freqArr[row]
        }
     
    }
    
    func checkFields(){
        //disable save button if field is empty
        if !titleField.hasText  || !dueDateField.hasText || !frequencyField.hasText {
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
        let titleText = titleField.text
        let freqText = freqArr[frequencyPicker.selectedRow(inComponent: 0)]
            
        completion?(titleText ?? "", datePicker.date, freqText)
        
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
        
        
        self.view.endEditing(true)
        
    }
    
    func createFrequencyPicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        //bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedFrequency))
        toolbar.setItems([doneBtn], animated: true)
             
        //assign toolbar
        frequencyField.inputAccessoryView = toolbar
        
        //assign date picker to text field
        frequencyField.inputView = frequencyPicker
     
        self.view.endEditing(true)
             
        
    }
    
    @objc func donePressedFrequency() {
        frequencyField.endEditing(true)
        frequencyField.resignFirstResponder()
        textFieldDidEndEditing(frequencyField)
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
        dueDateField.resignFirstResponder()
        textFieldDidEndEditing(dueDateField)
    }
    
    
 
    

}

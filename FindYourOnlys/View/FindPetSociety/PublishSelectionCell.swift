//
//  PublishSelectionCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishSelectionCell: UITableViewCell {

    @IBOutlet weak var selectionLabel: UILabel!
    
    @IBOutlet weak var selectionTextField: UITextField! {
        
        didSet {
        
            let picker = UIPickerView()
            
//            picker.dataSource = self
//            
//            picker.delegate = self
            
            selectionTextField.inputView = picker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage(named: "Icons_24px_DropDown"),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            selectionTextField.rightView = button
            
            selectionTextField.rightViewMode = .always
            
            selectionTextField.inputAccessoryView = customDoneToolBar()
            
            selectionTextField.delegate = self
            
        }
    }
    
    func customDoneToolBar() -> UIToolbar {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolbar.setItems([flexibleSpace, doneBtn], animated: true)
        
        return toolbar
    }
    
    @objc func donePressed(){

//        view.endEditing(true)
    }
    
}

//extension PublishSelectionCell: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//
//        1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//
//        categories.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//
//        categories[row].rawValue
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        categoryTextField.text = categories[row].rawValue
//    }
//
//}

extension PublishSelectionCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}

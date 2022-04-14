//
//  PublishSelectionCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

//protocol PublishSelectionCellDelegate: AnyObject {
//
//    func didChangeCity(_ cell: PublishBasicCell, with city: String)
//
//    func didChangeColor(_ cell: PublishBasicCell, with color: String)
//}

class PublishSelectionCell: PublishBasicCell {
    
    private enum City: String, CaseIterable {
        
        case keelung = "基隆市"
        
        case taipei = "台北市"
        
        case newTaipei = "新北市"
        
        case taoyuan = "桃園市"
        
        case hsinchuCountry = "新竹縣"
        
        case hsinchu = "新竹市"
        
        case miaoli = "苗栗市"
        
        case miaoliCountry = "苗栗縣"
        
        case taichung = "台中市"
        
        case changhuaCountry = "彰化縣"
        
        case changhua = "彰化市"
        
        case nantou = "南投市"
        
        case nantouCountry = "南投縣"
        
        case yunlin = "雲林縣"
        
        case chiayiCountry = "嘉義縣"
        
        case chiayi = "嘉義市"
        
        case tainan = "台南市"
        
        case kaohsiung = "高雄市"
        
        case pingtungCountry = "屏東縣"
        
        case pingtung = "屏東市"
        
        case yilanCountry = "宜蘭縣"
        
        case yilan = "宜蘭市"
        
        case hualianCountry = "花蓮縣"
        
        case hualian = "花蓮市"
        
        case taitung = "台東市"
        
        case taitungCountry = "台東縣"
        
        case penghu = "澎湖縣"
        
        case kinmen = "金門縣"
        
        case lienchiang = "連江縣"
    }

    private enum PetColor: String, CaseIterable {
        
        case red = "紅色"
        
        case white = "白色"
        
        case black = "綠色"
        
        case brown = "棕色"
        
        case mix = "虎斑"
        
        case yellow = "黃色"
        
        case blue = "藍色"
        
        case gray = "灰色"
        
    }
    
//    weak var delegate: PublishSelectionCellDelegate?

    @IBOutlet weak var selectionLabel: UILabel!
    
    @IBOutlet weak var selectionTextField: ContentInsetTextField! {
        
        didSet {
        
            let picker = UIPickerView()
            
            picker.dataSource = self
            
            picker.delegate = self
            
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
            
//            selectionTextField.inputAccessoryView = customDoneToolBar()
            
            selectionTextField.delegate = self
            
        }
    }
    
    override func layoutCell(category: String) {
        
        selectionLabel.text = category
        
    }
    
    func customDoneToolBar() -> UIToolbar {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolbar.setItems([flexibleSpace, doneBtn], animated: true)
        
        return toolbar
    }
    
    func passData() {
        
        guard
            let text = selectionTextField.text
                
        else { return }
        
        if selectionLabel.text == PublishContentCategory.city.rawValue {
            
            delegate?.didChangeCity(self, with: text)
            
        } else {
            
            delegate?.didChangeColor(self, with: text)
        }
        
    }
    
    @objc func donePressed(){

        selectionTextField.endEditing(true)
    }
    
}
// MARK: - UIPickerViewDelegate and Datasource
extension PublishSelectionCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if selectionLabel.text == PublishContentCategory.city.rawValue {
            
            return City.allCases.count
            
        } else {
            
            return PetColor.allCases.count
        }
        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectionLabel.text == PublishContentCategory.city.rawValue {
            
            return City.allCases[row].rawValue
            
        } else {
            
            return PetColor.allCases[row].rawValue
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if selectionLabel.text == PublishContentCategory.city.rawValue {
            
            selectionTextField.text = City.allCases[row].rawValue
            
        } else {
            
            selectionTextField.text = PetColor.allCases[row].rawValue
        }
    }

}

// MARK: - UITextFieldDelegate
extension PublishSelectionCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        passData()
    }
}

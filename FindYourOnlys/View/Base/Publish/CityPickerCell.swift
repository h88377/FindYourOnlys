//
//  CityPickerCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class CityPickerCell: BasePublishCell {
    
    private enum City: String, CaseIterable {
        
        case keelung = "基隆市"
        
        case taipei = "臺北市"
        
        case newTaipei = "新北市"
        
        case taoyuan = "桃園市"
        
        case hsinchuCountry = "新竹縣"
        
        case hsinchu = "新竹市"
        
        case miaoli = "苗栗市"
        
        case miaoliCountry = "苗栗縣"
        
        case taichung = "臺中市"
        
        case changhuaCountry = "彰化縣"
        
        case changhua = "彰化市"
        
        case nantou = "南投市"
        
        case nantouCountry = "南投縣"
        
        case yunlin = "雲林縣"
        
        case chiayiCountry = "嘉義縣"
        
        case chiayi = "嘉義市"
        
        case tainan = "臺南市"
        
        case kaohsiung = "高雄市"
        
        case pingtungCountry = "屏東縣"
        
        case pingtung = "屏東市"
        
        case yilanCountry = "宜蘭縣"
        
        case yilan = "宜蘭市"
        
        case hualianCountry = "花蓮縣"
        
        case hualian = "花蓮市"
        
        case taitung = "臺東市"
        
        case taitungCountry = "臺東縣"
        
        case penghu = "澎湖縣"
        
        case kinmen = "金門縣"
        
        case lienchiang = "連江縣"
    }

    private enum PetColor: String, CaseIterable {
        
        case red = "紅色"
        
        case white = "白色"
        
        case black = "黑色"
        
        case brown = "棕色"
        
        case mix = "虎斑"
        
        case yellow = "黃色"
        
        case blue = "藍色"
        
        case gray = "灰色"
        
        case green = "綠色"
        
    }

    // MARK: - Properties
    
    @IBOutlet private weak var selectionLabel: UILabel! {
        
        didSet {
            
            selectionLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var selectionTextField: ContentInsetTextField! {
        
        didSet {
        
            let picker = UIPickerView()
            
            picker.dataSource = self
            
            picker.delegate = self
            
            selectionTextField.inputView = picker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.pickerDropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            selectionTextField.rightView = button
            
            selectionTextField.rightViewMode = .always
            
            selectionTextField.delegate = self
            
            selectionTextField.textColor = .projectTextColor
        }
    }
    
    // MARK: - Methods
    
    override func layoutCell(category: String, article: Article? = nil) {
        
        selectionLabel.text = category
        
        if
            let article = article {
            
            switch category {
                
            case PublishContentCategory.city.rawValue:
                
                selectionTextField.text = article.city
                
            case PublishContentCategory.color.rawValue:
                
                selectionTextField.text = article.color
                
            default:
                
                selectionTextField.text = ""
            }
        }
    }
    
    override func layoutCell(category: String, condition: AdoptFilterCondition? = nil) {
        
        selectionLabel.text = category
        
        if
            let condition = condition {
            
            switch category {
                
            case AdoptFilterCategory.city.rawValue:
                
                selectionTextField.text = condition.city
                
            case AdoptFilterCategory.color.rawValue:
                
                selectionTextField.text = condition.color
                
            default:
                
                selectionTextField.text = ""
            }
        }
    }
    
    override func layoutCell(category: String, findCondition: FindPetSocietyFilterCondition? = nil) {
        
        selectionLabel.text = category
        
        if
            let findCondition = findCondition {
            
            switch category {
                
            case FindPetSocietyFilterCategory.city.rawValue:
                
                selectionTextField.text = findCondition.city
                
            case FindPetSocietyFilterCategory.color.rawValue:
                
                selectionTextField.text = findCondition.color
                
            default:
                
                selectionTextField.text = ""
            }
        }
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
    
    @objc func donePressed() {

        selectionTextField.endEditing(true)
    }
    
}
// MARK: - UIPickerViewDelegate and Datasource

extension CityPickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
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
extension CityPickerCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        passData()
    }
}

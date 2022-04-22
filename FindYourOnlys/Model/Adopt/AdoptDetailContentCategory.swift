//
//  AdoptDetailDescription.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation
import UIKit

enum AdoptDetailContentCategory: String, CaseIterable {
    
    case id = "動物流水編號"
    
    case age = "動物年齡"
    
    case color = "動物毛色"
    
    case bodyType = "動物體型"
    
    case foundPlace = "尋獲地點"
    
    case sterilization = "是否節育"
    
    case bacterin = "是否打狂犬疫苗"
    
    case openDate = "開放領養時間"
    
    case closedDate = "截止領養時間"
    
    case updatedDate = "資料更新時間"
    
    case createdDate = "資料建立時間"
    
    case shelterName = "領養機構"
    
    case address = "領養地址"
    
    case telephone = "領養電話"
    
    case remark = "備註"
    
//        case variety = "animal_Variety"
    //        case location = "animal_place"
            
    //        case kind = "animal_kind"
            
    //        case sex = "animal_sex"
    //        case status = "animal_status"
    //        case photoURLString = "album_file"
    
    func cellForIndexPath(_ indexPath: IndexPath, tableView: UITableView, viewModel: PetViewModel) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: AdoptDetailDecriptionTableViewCell.identifier, for: indexPath) as? AdoptDetailDecriptionTableViewCell
                
        else { return UITableViewCell() }
        
        let pet = viewModel.pet

        switch self {

        case .id:

            cell.configureCell(description: rawValue, content: "\(pet.id)")

        case .age:
            
            cell.configureCell(description: rawValue, content: pet.age)
            
        case .color:
            
            cell.configureCell(description: rawValue, content: pet.color)
            
        case .bodyType:
            
            cell.configureCell(description: rawValue, content: pet.bodyType)
        
        case .foundPlace:
            
            cell.configureCell(description: rawValue, content: pet.foundPlace)
        
        case .sterilization:
            
            cell.configureCell(description: rawValue, content: pet.sterilization)
        
        case .bacterin:
            
            cell.configureCell(description: rawValue, content: pet.bacterin)
        
        case .openDate:
            
            cell.configureCell(description: rawValue, content: pet.openDate)
        
        case .closedDate:
            
            cell.configureCell(description: rawValue, content: pet.closedDate)
        
        case .updatedDate:
            
            cell.configureCell(description: rawValue, content: pet.updatedDate)
        
        case .createdDate:
            
            cell.configureCell(description: rawValue, content: pet.createdDate)
            
        case .shelterName:
            
            cell.configureCell(description: rawValue, content: pet.shelterName)
        
        case .address:
            
            cell.configureCell(description: rawValue, content: pet.address)
        
        case .telephone:
            
            cell.configureCell(description: rawValue, content: pet.telephone)
        
        case .remark:
            
            cell.configureCell(description: rawValue, content: pet.remark)
        }

        return cell
    }
}

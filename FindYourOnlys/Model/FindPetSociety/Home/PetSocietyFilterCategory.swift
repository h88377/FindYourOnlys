//
//  PetSocietyFilterCategory.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

enum PetSocietyFilterCategory: String, CaseIterable {
    
    case city = "請選擇縣市"
    
    case color = "請選擇顏色"
    
    case petKind = "請選擇類別"
    
    case postType = "請選擇遺失/尋獲"
    
    func identifier() -> String {
        
        switch self {
            
        case .color, .city: return PublishSelectionCell.identifier
            
        case .petKind, .postType: return PublishKindCell.identifier
            
        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)
        
        guard
            let basicCell = cell as? PublishBasicCell else { return cell }
        
        switch self {
            
        case .city:
            
            basicCell.layoutCell(category: rawValue)
            
        case .color:
            
            basicCell.layoutCell(category: rawValue)
            
        case .petKind:
            
            basicCell.layoutCell(category: rawValue)
            
        case .postType:
            
            basicCell.layoutCell(category: rawValue)
        }
        
        return basicCell
        
    }
}

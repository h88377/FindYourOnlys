//
//  AdoptFilterCategory.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/22.
//

import UIKit

enum AdoptFilterCategory: String, CaseIterable {
    
    case city = "請選擇縣市"
    
    case petKind = "請選擇類別"
    
    case sex = "選擇動物性別"
    
    case color = "請選擇顏色"
    
    func identifier() -> String {

        switch self {

        case .city, .color: return PublishSelectionCell.identifier

        case .petKind, .sex: return PublishKindCell.identifier

        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, tableView: UITableView, condition: AdoptFilterCondition? = nil) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)

        guard let basicCell = cell as? PublishBasicCell else { return cell }
        
        switch self {
            
        case .sex:
            
            basicCell.layoutCell(category: rawValue, condition: condition)
            
        case .city:
            
            basicCell.layoutCell(category: rawValue, condition: condition)
            
        case .color:
            
            basicCell.layoutCell(category: rawValue, condition: condition)
            
        case .petKind:
            
            basicCell.layoutCell(category: rawValue, condition: condition)
            
        }

        return basicCell
    }
}

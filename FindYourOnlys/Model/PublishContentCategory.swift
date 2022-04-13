//
//  PublishContentCategory.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

enum PublishContentCategory: String, CaseIterable {
    
    case user = ""
    
    case city = "請選擇縣市"
    
    case color = "請選擇顏色"
    
    case petKind = "請選擇類別"
    
    case petDescription = "請選擇遺失/尋獲"
    
    case content = " "
    
    func identifier() -> String {

        switch self {

        case .user: return PublishUserCell.identifier

        case .color, .city: return PublishSelectionCell.identifier
            
        case .petKind, .petDescription: return PublishKindCell.identifier

        case .content: return PublishContentCell.identifier

        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)

        guard let basicCell = cell as? PublishBasicCell else { return cell }
        
        switch self {
            
        case .user:
            
            basicCell.layoutCell()
            
        case .city:
            
            basicCell.layoutCell(category: rawValue)
            
        case .color:
            
            basicCell.layoutCell(category: rawValue)
            
        case .petKind:
            
            basicCell.layoutCell(category: rawValue)
            
        case .petDescription:
            
            basicCell.layoutCell(category: rawValue)
            
        case .content:
            
            basicCell.layoutCell()
        }

        return basicCell
    }
}

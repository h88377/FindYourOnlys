//
//  ShareContentCategory.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

enum ShareContentCategory: String, CaseIterable {
    
    case user = ""
    
    case city = "請選擇縣市"
    
    case petKind = "請選擇類別"
    
    case content = " "
    
    func identifier() -> String {

        switch self {

        case .user: return PublishUserCell.identifier

        case .city: return PublishSelectionCell.identifier
            
        case .petKind: return PublishKindCell.identifier

        case .content: return PublishContentCell.identifier

        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)

        guard
            let basicCell = cell as? PublishBasicCell else { return cell }
        
        switch self {
            
        case .user:
            
            basicCell.layoutCell()
            
        case .city:
            
            basicCell.layoutCell(category: rawValue)
            
        case .petKind:
            
            basicCell.layoutCell(category: rawValue)
            
        case .content:
            
            basicCell.layoutCell()
        }

        return basicCell
    }
}

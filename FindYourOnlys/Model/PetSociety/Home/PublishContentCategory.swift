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
    
    case postType = "請選擇遺失/尋獲"
    
    case content = " "
    
    func identifier() -> String {

        switch self {

        case .user: return PublishUserCell.identifier

        case .color, .city: return CityPickerCell.identifier
            
        case .petKind, .postType: return KindSelectionCell.identifier

        case .content: return PublishContentCell.identifier

        }
    }
    
    static func getCategory(with type: ArticleType) -> [PublishContentCategory] {
        
        switch type {
            
        case .find:
            
            return PublishContentCategory.allCases
            
        case .share:
            
            return [.user, .city, .petKind, .content]
        }
    }
    
    func cellForIndexPath(_ indexPath: IndexPath, tableView: UITableView, article: Article? = nil) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(), for: indexPath)

        guard
            let basicCell = cell as? BasePublishCell else { return cell }
        
        switch self {
            
        case .user:
            
            basicCell.layoutCell(article: article)
            
        case .city:
            
            basicCell.layoutCell(category: rawValue, article: article)
            
        case .color:
            
            basicCell.layoutCell(category: rawValue, article: article)
            
        case .petKind:
            
            basicCell.layoutCell(category: rawValue, article: article)
            
        case .postType:
            
            basicCell.layoutCell(category: rawValue, article: article)
            
        case .content:
            
            basicCell.layoutCell(article: article)
        }

        return basicCell
    }
}

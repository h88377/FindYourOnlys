//
//  TimeInterval.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import Foundation

extension TimeInterval {
    
    var formatted: String {
        
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .full
        
        formatter.allowedUnits = [.hour, .minute]
        
        return formatter.string(from: self) ?? ""
    }
    
    var formatedTime: String {
        
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        
        let date = NSDate(timeIntervalSince1970: self)

        let dateString = formatter.string(from: date as Date)
        
        return dateString
    }
}

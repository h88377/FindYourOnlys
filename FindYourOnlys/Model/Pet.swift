//
//  Pet.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

struct Pet: Codable {
    
    var userID: String?
    
    var favoriteID: String?
    
    let id: Int
    
    let location: String
    
    let kind: String
    
    let sex: String
    
    let bodyType: String
    
    let color: String
    
    let age: String
    
    let sterilization: String
    
    let bacterin: String
    
    let foundPlace: String
    
    let status: String
    
    let remark: String
    
    let openDate: String
    
    let closedDate: String
    
    let updatedDate: String
    
    let createdDate: String
    
    let photoURLString: String
    
    let address: String
    
    let telephone: String
    
    let variety: String
    
    enum CodingKeys: String, CodingKey {
        
        case userID, favoriteID
        
        case id = "animal_id"
        
        case location = "animal_place"
        
        case kind = "animal_kind"
        
        case sex = "animal_sex"
        
        case bodyType = "animal_bodytype"
        
        case color = "animal_colour"
        
        case age = "animal_age"
        
        case sterilization = "animal_sterilization"
        
        case bacterin = "animal_bacterin"
        
        case foundPlace = "animal_foundplace"
        
        case status = "animal_status"
        
        case remark = "animal_remark"
        
        case openDate = "animal_opendate"
        
        case closedDate = "animal_closeddate"
        
        case updatedDate = "animal_update"
        
        case createdDate = "animal_createtime"
        
        case photoURLString = "album_file"
        
        case address = "shelter_address"
        
        case telephone = "shelter_tel"
        
        case variety = "animal_Variety"
    }
}


//"animal_id": 249909,
//        "animal_subid": "1110407C01",
//        "animal_area_pkid": 22,
//        "animal_shelter_pkid": 82,
//        "animal_place": "金門縣動物收容中心",
//        "animal_kind": "貓",
//        "animal_sex": "M",
//        "animal_bodytype": "SMALL",
//        "animal_colour": "虎斑色",
//        "animal_age": "",
//        "animal_sterilization": "F",
//        "animal_bacterin": "F",
//        "animal_foundplace": "金沙鎮西園里后珩",
//        "animal_title": "",
//        "animal_status": "OPEN",
//        "animal_remark": "",
//        "animal_caption": "",
//        "animal_opendate": "2022-04-07",
//        "animal_closeddate": "2999-12-31",
//        "animal_update": "2022/04/09",
//        "animal_createtime": "2022/04/07",
//        "shelter_name": "金門縣動物收容中心",
//        "album_file": "https://asms.coa.gov.tw/amlapp/upload/pic/811f4a82-51ba-4262-ae79-2f4dfc9070d5_org.jpg",
//        "album_update": "",
//        "cDate": "2022/04/09",
//        "shelter_address": "金門縣金湖鎮裕民農莊20號",
//        "shelter_tel": "082-336625",
//        "animal_Variety": "混種貓"

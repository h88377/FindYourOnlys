//
//  ShelterProvider.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import Foundation

enum ShelterName: String, CaseIterable {
    
    case keelung = "基隆市寵物銀行"
    
    case taipei = "臺北市動物之家"
    
    case banchiao = "新北市板橋區公立動物之家"
    
    case shindian = "新北市新店區公立動物之家"
    
    case chunhia = "新北市中和區公立動物之家"
    
    case tamshuia = "新北市淡水區公立動物之家"
    
    case taoyuan = "桃園市動物保護教育園區"
    
    case hsinchuCountry = "新竹縣動物收容所"
    
    case hsinchu = "新竹市動物收容所"
    
    case newtaipei = "新北市政府動物保護防疫處"
    
    case miaoliCountry = "苗栗縣生態保育教育中心"
    
    case taichung = "臺中市動物之家南屯園區"
    
    case hiuali = "臺中市動物之家后里園區"
    
    case changhuaCountry = "彰化縣流浪狗中途之家"
    
    case nantou = "南投縣公立動物收容所"
    
    case yunlin = "雲林縣流浪動物收容所"
    
    case chiayiCountry = "嘉義縣流浪犬中途之家"
    
    case chiayi = "嘉義市流浪犬收容中心"
    
    case tainan = "臺南市動物之家灣裡站"
    
    case tainanshanhua = "臺南市動物之家善化站"
    
    case kaohsiung = "高雄市壽山動物保護教育園區"
    
    case ianchao = "高雄市燕巢動物保護關愛園區"
    
    case pingtungCountry = "屏東縣流浪動物收容所"
    
    case yilanCountry = "宜蘭縣流浪動物中途之家"
    
    case hualianCountry = "花蓮縣流浪犬中途之家"
    
    case taitungCountry = "臺東縣動物收容中心"
    
    case penghu = "澎湖縣流浪動物收容中心"
    
    case kinmen = "金門縣動物收容中心"
    
    case lienchiang = "連江縣流浪犬收容中心"
    
    case ruifang = "新北市瑞芳區公立動物之家"
    
    case wuku = "新北市五股區公立動物之家"
    
    case bali = "新北市八里區公立動物之家"
    
    case shanchi = "新北市三芝區公立動物之家"
    
    
}

class ShelterProvider {
    
    static let shared = ShelterProvider()
    
    
    // MARK: - convert functions
    private func convertSheltersToViewModels(from shelters: [Shelter]) -> [ShelterViewModel] {
        
        var viewModels = [ShelterViewModel]()
        
        for shelter in shelters {
            
            let viewModel = ShelterViewModel(model: shelter)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setShelters(with viewModels: Box<[ShelterViewModel]>, shelter: [Shelter]) {
        
        viewModels.value = convertSheltersToViewModels(from: shelter)
    }
    
}

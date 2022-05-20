//
//  AdoptManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

enum HTTPClientError: Error {
    
    case urlError
    
    case decodeDataFail
    
    case clientError(Data)
    
    case serverError
    
    case internetError
    
    case unexpectedError
    
    var errorMessage: String {
        
        switch self {
        case .urlError:
            
            return "網路異常，請稍後再嘗試一次"
            
        case .decodeDataFail:
            
            return "讀取資料失敗，請稍後再嘗試一次"
            
        case .clientError(_):
            
            return "網路異常，請確認網路狀態"
            
        case .serverError:
            
            return "伺服器異常，請稍後再嘗試一次"
            
        case .internetError:
            
            return "網路異常，請確認網路狀態"
            
        case .unexpectedError:
            
            return "發生預期外的異常，請稍後再嘗試一次"
        }
    }
}

class PetHTTPClient {
    
    static let shared = PetHTTPClient()
    
    func requestPet(
        with condition: AdoptFilterCondition,
        paging: Int?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        
        let urlString = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx"
        
        let parameters: [String: String]
        
        switch paging == nil {
            
        case true:
            
            parameters = ["UnitId": "QcbUEzN6E6DL",
                          "shelter_address": condition.city,
                          "animal_kind": condition.petKind,
                          "animal_sex": condition.sex,
                          "animal_colour": condition.color
            ]
        case false:
            
            parameters = ["UnitId": "QcbUEzN6E6DL",
                          "$top": "20",
                          "$skip": "\(20 * (paging! - 1))",
                          "shelter_address": condition.city,
                          "animal_kind": condition.petKind,
                          "animal_sex": condition.sex,
                          "animal_colour": condition.color
            ]
        }
        
        guard
            var component = URLComponents(string: urlString)
                
        else { return completion(.failure(HTTPClientError.urlError)) }
        
        component.queryItems = parameters.map { (key, value) in
            
            URLQueryItem(name: key, value: value)
        }
        
        let request = URLRequest(url: component.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else { return completion(.failure(HTTPClientError.internetError)) }
            
            // swiftlint:disable force_cast
            let httpResponse = response as! HTTPURLResponse
            // swiftlint:enable force_cast
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
                
            case 200..<300:
                
                completion(.success(data!))
                
            case 400..<500:
                
                completion(.failure(HTTPClientError.clientError(data!)))
                
            case 500..<600:
                
                completion(.failure(HTTPClientError.serverError))
                
            default: return
                
                completion(.failure(HTTPClientError.unexpectedError))
            }
        }
        
        task.resume()
    }
    
}

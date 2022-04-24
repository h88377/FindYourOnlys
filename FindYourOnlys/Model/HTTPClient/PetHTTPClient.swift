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

    case unexpectedError
}

class PetHTTPClient {
    
    static let shared = PetHTTPClient()
    
    // First load
    func requestPet(with condition: AdoptFilterCondition? = nil, completion: @escaping (Result<Data, Error>)-> Void) {
        
        let urlString = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx"
        
        let parameters: [String: String]
        
        switch condition == nil {
            
        case true:
            
            parameters = ["UnitId": "QcbUEzN6E6DL",
                              "$top": "5",
                              "$skip": "0",
                              ]
        case false:
            
            parameters = ["UnitId": "QcbUEzN6E6DL",
                              "$top": "20",
                              "$skip": "0",
                              "shelter_address": condition!.city,
                              "animal_kind": condition!.petKind,
                              "animal_sex": condition!.sex,
                              "animal_colour": condition!.color
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
            
            guard error == nil else { return completion(.failure(error!)) }
                
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
    
    func requestPet(with condition: AdoptFilterCondition? = nil, paging: Int, completion: @escaping (Result<Data, Error>)-> Void) {
        
        let urlString = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx"
        
        let parameters: [String: String]
        
        switch condition == nil {
            
        case true:
            
            parameters = ["UnitId": "QcbUEzN6E6DL",
                              "$top": "5",
                              "$skip": "\(5 * (paging - 1))"
                              ]
        case false:
            
            parameters = ["UnitId": "QcbUEzN6E6DL",
                              "$top": "20",
                              "$skip": "0",
                              "shelter_address": condition!.city,
                              "animal_kind": condition!.petKind,
                              "animal_sex": condition!.sex,
                              "animal_colour": condition!.color
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
            
            guard error == nil else { return completion(.failure(error!)) }
                
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

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
    
    //First load
    func requestPet(completion: @escaping (Result<Data, Error>)-> Void) {
        
        let urlString = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx"
        
        let parameters = ["UnitId": "QcbUEzN6E6DL", "$top": "10", "$skip": "$0"]
        
//        let parameters = ["UnitId": "QcbUEzN6E6DL"]
        
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
    
    func requestPet(with city: String, completion: @escaping (Result<Data, Error>)-> Void) {
        
        let urlString = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx"
        
//        let parameters = ["UnitId": "QcbUEzN6E6DL", "$top": "1000", "$skip": "$0", "shelter_address": city]
        let parameters = ["UnitId": "QcbUEzN6E6DL", "shelter_address": city]
        
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
    
//    func fetchPet2(completion: @escaping (Result<[Pet].self, Error>)-> Void) {
//
//        HTTPClient.shared.request(PetRequest.adopt, with: ["UnitId": "QcbUEzN6E6DL"]) { result in
//            switch result {
//            case .success(let data):
//
//                do {
//                    let groupDetail = try self.decoder.decode(
//                        STSuccessParser<GroupDetail>.self,
//                        from: data
//                    )
//
//                    DispatchQueue.main.async {
//
//                       completion(Result.success(groupDetail.data))
//                    }
//
//                } catch {
//                    print(error)
//
//                    completion(Result.failure(error))
//                }
//
//            case .failure(let error):
//                completion(Result.failure(error))
//            }
//        }
//
//    }
    
}

//
//  HTTPClient.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

//enum HTTPClientError: Error {
//
//    case decodeDataFail
//
//    case clientError(Data)
//
//    case serverError
//
//    case unexpectedError
//}
//
//enum HTTPMethod: String {
//
//    case GET
//
//    case POST
//}
//
//enum HTTPHeaderField: String {
//
//    case contentType = "Content-Type"
//
//    case auth = "Authorization"
//}
//
//enum HTTPHeaderValue: String {
//
//    case json = "application/json"
//}
//
//protocol AdoptRequest {
//    
//    var headers: [String: String] { get }
//    
//    var body: Data? { get }
//    
//    var method: String { get }
//    
//}
//
//extension AdoptRequest {
//    
//    func makeRequest(with parameters: [String: String]) -> URLRequest {
//
//        let urlString = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx"
//        
//        var component = URLComponents(string: urlString)!
//        
//        component.queryItems = parameters.map { (key, value) in
//            
//            URLQueryItem(name: key, value: value)
//        }
//
//        var request = URLRequest(url: component.url!)
//
//        request.allHTTPHeaderFields = headers
//        
//        request.httpBody = body
//
//        request.httpMethod = method
//
//        return request
//    }
//}
//
//class HTTPClient {
//    
//    static let shared = HTTPClient()
//
//    private init() { }
//    
//    func request(
//        _ adoptRequest: AdoptRequest, with parameters: [String: String],
//        completion: @escaping ((Result<Data, Error>) -> Void)
//    ) {
//
//        URLSession.shared.dataTask(
//            with: adoptRequest.makeRequest(with: parameters),
//            completionHandler: { (data, response, error) in
//
//            guard error == nil else {
//
//                return completion(Result.failure(error!))
//            }
//                
//            // swiftlint:disable force_cast
//            let httpResponse = response as! HTTPURLResponse
//            // swiftlint:enable force_cast
//            let statusCode = httpResponse.statusCode
//
//            switch statusCode {
//
//            case 200..<300:
//
//                completion(Result.success(data!))
//
//            case 400..<500:
//
//                completion(Result.failure(HTTPClientError.clientError(data!)))
//
//            case 500..<600:
//
//                completion(Result.failure(HTTPClientError.serverError))
//
//            default: return
//
//                completion(Result.failure(HTTPClientError.unexpectedError))
//            }
//
//        }).resume()
//    }
//    
//}

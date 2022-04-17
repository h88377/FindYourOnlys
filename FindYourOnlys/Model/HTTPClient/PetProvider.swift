//
//  PetManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class PetProvider {
    
    static let shared = PetProvider()
    
    func fetchPet(completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        PetHTTPClient.shared.requestPet { result in
            
            switch result {
                
            case.success(let data):
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let pets = try decoder.decode([Pet].self, from: data)
                    
                    completion(.success(pets))
                }
                
                catch {
                    
                    completion(.failure(HTTPClientError.decodeDataFail))
                    
                }
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
}
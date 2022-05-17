//
//  PetManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class PetProvider {
    
    private init() {}
    
    static let shared = PetProvider()
    
    func fetchPet(
        with condition: AdoptFilterCondition,
        paging: Int? = nil,
        completion: @escaping (Result<[Pet], Error>) -> Void
    ) {
        
        PetHTTPClient.shared.requestPet(with: condition, paging: paging) { result in
            
            switch result {
                
            case.success(let data):
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let pets = try decoder.decode([Pet].self, from: data)
                    
                    completion(.success(pets))
                } catch {
                    
                    completion(.failure(HTTPClientError.decodeDataFail))
                    
                }
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func setPets(petViewModels: Box<[PetViewModel]>, with pets: [Pet]) {
        
        petViewModels.value = convertPetsToViewModels(from: pets)
    }
    
    func convertPetsToViewModels(from pets: [Pet]) -> [PetViewModel] {
        
        var viewModels = [PetViewModel]()
        
        for pet in pets {
            
            let viewModel = PetViewModel(model: pet)
            
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
}

//
//  StorageManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation
import CoreData
import SwiftUI

enum LocalStorageError: Error {
    
    case fetchPetError
    
    case updatePetError
    
    var errorMessage: String {
        
        switch self {
        case .fetchPetError:
            
            return "讀取資料失敗"
            
        case .updatePetError:
            
            return "更新資料失敗"
        }
    }
}

class StorageManager {
    
    private init() {
        
        print(" Core data file path: \(NSPersistentContainer.defaultDirectoryURL())")
    }
    
    // MARK: - Properties
    
    static let shared = StorageManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "FindYourOnlys")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    // MARK: - Methods
    
    func saveContext(completion: (Result<Void, Error>) -> Void) {
        
        let context = StorageManager.shared.persistentContainer.viewContext
        
        if context.hasChanges {
            
            do {
                
                try context.save()
                
                completion(.success(()))
                
            } catch {
                
                completion(.failure(LocalStorageError.updatePetError))
            }
        }
    }
    
    func fetchPet(completion: ((Result<[LSPet], Error>) -> Void)) {
        
        let request: NSFetchRequest<LSPet> = LSPet.fetchRequest()
        
        do {
            
            let lsPets = try StorageManager.shared.persistentContainer.viewContext.fetch(request)
            
            completion(.success(lsPets))
            
        } catch {
            
            completion(.failure(LocalStorageError.fetchPetError))
        }
    }
    
    func savePetInFavorite(
        with pet: Pet,
        completion: (Result<Void, Error>) -> Void
    ) {
        
        let context = StorageManager.shared.persistentContainer.viewContext
        
        let lsPet = LSPet(entity: LSPet.entity(), insertInto: context)
        
        lsPet.photoURLString = pet.photoURLString
        
        lsPet.variety = pet.variety
        
        lsPet.sex = pet.sex
        
        lsPet.bodyType = pet.bodyType
        
        lsPet.location = pet.location
        
        lsPet.status = pet.status
        
        lsPet.kind = pet.kind
        
        lsPet.age = pet.age
        
        lsPet.bacterin = pet.bacterin
        
        lsPet.closedDate = pet.closedDate
        
        lsPet.openDate = pet.openDate
        
        lsPet.updatedDate = pet.updatedDate
        
        lsPet.createdDate = pet.createdDate
        
        lsPet.id = Int64(pet.id)
        
        lsPet.color = pet.color
        
        lsPet.sterilization = pet.sterilization
        
        lsPet.foundPlace = pet.foundPlace
        
        lsPet.remark = pet.remark
        
        lsPet.address = pet.address
        
        lsPet.telephone = pet.telephone
        
        lsPet.shelterName = pet.shelterName
        
        saveContext { result in
            
            switch result {
                
            case .success:
                
                completion(.success(()))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func removePetfromFavorite(lsPet: LSPet, completion: (Result<Void, Error>) -> Void) {
        
        let context = StorageManager.shared.persistentContainer.viewContext
        
        context.delete(lsPet)
        
        saveContext { result in
            
            switch result {
                
            case .success:
                
                completion(.success(()))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func convertLsPetsToPets(from lsPets: [LSPet]) -> [Pet] {
        
        var pets = [Pet]()
        
        for lsPet in lsPets {
            
            let pet = Pet(
                userID: lsPet.userID,
                favoriteID: lsPet.favoriteID,
                id: Int(lsPet.id),
                location: lsPet.location,
                kind: lsPet.kind,
                sex: lsPet.sex,
                bodyType: lsPet.bodyType,
                color: lsPet.color,
                age: lsPet.age,
                sterilization: lsPet.sterilization,
                bacterin: lsPet.bacterin,
                foundPlace: lsPet.foundPlace,
                status: lsPet.status,
                remark: lsPet.remark,
                openDate: lsPet.openDate,
                closedDate: lsPet.closedDate,
                updatedDate: lsPet.updatedDate,
                createdDate: lsPet.createdDate,
                photoURLString: lsPet.photoURLString,
                address: lsPet.photoURLString,
                telephone: lsPet.telephone,
                variety: lsPet.variety,
                shelterName: lsPet.shelterName)
            
            pets.append(pet)
        }
        
        return pets
    }
}

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
}

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {

        print(" Core data file path: \(NSPersistentContainer.defaultDirectoryURL())")
    }
    
    //Set this will cause app crash
//    let context = StorageManager.shared.persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "FindYourOnlys")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            
            if
                let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    func saveContext(completion: (Result<String, Error>) -> Void) {
        
        let context = StorageManager.shared.persistentContainer.viewContext
        
        if context.hasChanges {
            
            do {
                
                try context.save()
                
                completion(.success("success"))
                
            } catch {
                
                completion(.failure(LocalStorageError.updatePetError))
                
//                let nserror = error as NSError
//
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func savePetInFavorite(with petViewModel: PetViewModel, completion: (Result<String, Error>) -> Void) {
        
        let context = StorageManager.shared.persistentContainer.viewContext
        
        let lsPet = LSPet(entity: LSPet.entity(), insertInto: context)
        
        let pet = petViewModel.pet
        
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
                
            case .success(let success):
                
                completion(.success(success))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func removePetfromFavorite(lsPet: LSPet, completion: (Result<String, Error>) -> Void) {
        
        let context = StorageManager.shared.persistentContainer.viewContext
        
        context.delete(lsPet)
        
        saveContext { result in
            
            switch result {
                
            case .success(let success):
                
                completion(.success(success))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func fetchPet(completion: ((Result<[LSPet], Error>) -> Void)) {
        
        let request: NSFetchRequest<LSPet> = LSPet.fetchRequest()
        
        do {
            
            let lsPets = try StorageManager.shared.persistentContainer.viewContext.fetch(request)
            
            completion(.success(lsPets))
        }
        
        catch {
            
            completion(.failure(LocalStorageError.fetchPetError))
        }
    }
}

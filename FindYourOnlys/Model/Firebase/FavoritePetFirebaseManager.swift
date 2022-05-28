//
//  PetFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/11.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FavoritePetFirebaseManager {
    
    static let shared = FavoritePetFirebaseManager()
    
    private let database = Firestore.firestore()
    
    func fetchFavoritePets(completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        database
            .collection(FirebaseCollectionType.favoritePet.rawValue)
            .addSnapshotListener { snapshot, _ in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchPetError))
                        
                        return
                    }
                
                do {
                    
                    let pets = try snapshot.documents.map { try $0.data(as: Pet.self) }
                    
                    completion(.success(pets))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodePetError))
                }
            }
    }
    
    func fetchFavoritePet(
        pet: Pet,
        completion: @escaping (Result<[Pet], Error>)
        -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            database
                .collection(FirebaseCollectionType.favoritePet.rawValue)
                .whereField(FirebaseFieldType.userID.rawValue, isEqualTo: currentUser.id)
                .whereField(FirebaseFieldType.animalId.rawValue, isEqualTo: pet.id)
                .getDocuments { snapshot, _ in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchPetError))
                        
                        return
                    }
                    
                    do {
                        
                        let pets = try snapshot.documents.map { try $0.data(as: Pet.self) }
                        
                        completion(.success(pets))
                        
                    } catch {
                        
                        completion(.failure(FirebaseError.decodePetError))
                    }
                }
        }
    
    func saveFavoritePet(
        _ userID: String,
        with petViewModel: PetViewModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        let documentReference = database.collection(FirebaseCollectionType.favoritePet.rawValue).document()
        
        let documentId = documentReference.documentID
        
        do {
            
            var pet = petViewModel.pet
            
            pet.favoriteID = documentId
            
            pet.userID = userID
            
            try documentReference.setData(from: pet)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.updatePetError))
        }
    }
    
    func removeFavoritePet(with petViewModel: PetViewModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        database.collection(FirebaseCollectionType.favoritePet.rawValue).getDocuments { snapshot, _ in
            
            guard
                let snapshot = snapshot else {
                    
                    completion(.failure(FirebaseError.fetchPetError))
                    
                    return
                    
                }
            
            for index in 0..<snapshot.documents.count {
                
                do {
                    
                    let removePet = try snapshot.documents[index].data(as: Pet.self)
                    
                    if petViewModel.pet.userID == removePet.userID
                        && petViewModel.pet.id == removePet.id {
                        
                        let docID = snapshot.documents[index].documentID
                        
                        self.database
                            .collection(FirebaseCollectionType.favoritePet.rawValue)
                            .document("\(docID)")
                            .delete()
                        
                        completion(.success(()))
                    }
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodePetError))
                }
            }
        }
    }
    
    func removeFavoritePet(with userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        database.collection(FirebaseCollectionType.favoritePet.rawValue).getDocuments { snapshot, _ in
            
            guard
                let snapshot = snapshot else {
                    
                    completion(.failure(FirebaseError.fetchPetError))
                    
                    return
                }
            
            for index in 0..<snapshot.documents.count {
                
                do {
                    let removePet = try snapshot.documents[index].data(as: Pet.self)
                    
                    if removePet.userID == userId {
                        
                        let docID = snapshot.documents[index].documentID
                        
                        self.database
                            .collection(FirebaseCollectionType.favoritePet.rawValue)
                            .document("\(docID)")
                            .delete()
                    }
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodePetError))
                    
                    return
                }
            }
            completion(.success(()))
        }
    }
}

//
//  PetFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/11.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum FirebaseError: Error {
    
    case fetchPetError
    
    case decodePetError
    
    case updatePetError
    
    case fetchArticleError
    
    case updateArticleError
    
    case publishArticleError
    
    case decodeArticleError
    
    case deleteArticleError
    
    case uploadImageError
    
    case encodeImageError
    
    case fetchImageURLError
    
    case leaveCommentError
    
    case toggleLikeArticleError
    
    case fetchChatRoomError
    
    case deleteChatRoomError
    
    case fetchMessageError
    
    case deleteMessageError
    
    case sendMessageError
    
    case fetchFriendRequestError
    
    case decodeFriendRequestError
    
    case sendFriendRequestError
    
    case fetchUserError
    
    case deleteUserError
    
    case decodeUserError
    
    case createUserError
    
    case updateUserError
    
    case deleteFriendRequestError
    
    case addFriendRequestError
    
    case createChatRoomError
}

class FavoritePetFirebaseManager {
    
    static let shared = FavoritePetFirebaseManager()
    
    let db = Firestore.firestore()
    
    func fetchFavoritePets(completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.favoritePet.rawValue)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchPetError))
                        
                        return
                        
                    }
                
                var pets = [Pet]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let pet = try document.data(as: Pet.self, decoder: Firestore.Decoder())
                        
                        pets.append(pet)
                    }
                    catch {
                        
                        completion(.failure(FirebaseError.decodePetError))
                    }
                }
                
                completion(.success(pets))
            }
    }
    
    func saveFavoritePet(_ userID: String, with petViewModel: PetViewModel, completion: @escaping (Result<String, Error>) -> Void) {
        
        // Check if there have existed same pet on firestore when call this func in viewModel
        let documentReference = db.collection(FirebaseCollectionType.favoritePet.rawValue).document()
        
        let documentId = documentReference.documentID
        
        do {
            
            var pet = petViewModel.pet
            
            pet.favoriteID = documentId
            
            pet.userID = userID
            
            try documentReference.setData(from: pet)
            
            completion(.success("sucess"))
            
        } catch {
            
            completion(.failure(FirebaseError.updatePetError))
        }
    }
    
    func removeFavoritePet(with petViewModel: PetViewModel, completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.favoritePet.rawValue).getDocuments { snapshot, error in
            
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
                        
                        self.db.collection(FirebaseCollectionType.favoritePet.rawValue).document("\(docID)").delete()
                        
                        completion(.success("success"))
                    }
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodePetError))
                }
            }
        }
    }
    
    func removeFavoritePet(with userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.favoritePet.rawValue).getDocuments { snapshot, error in
            
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
                        
                        self.db.collection(FirebaseCollectionType.favoritePet.rawValue).document("\(docID)").delete()
                    }
                    
                    completion(.success("success"))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodePetError))
                }
            }
//            completion(nil)
        }
    }
}

//    func addUserIDInFavoritePet(with userID: Int, completion: @escaping (Error?) -> Void) {
//
//
//
//        let documentReference = db.collection(FirebaseCollectionType.favoritePet.rawValue).document()
//
//        documentReference.getDocument { document, error in
//
//            guard
//                let document = document,
//                document.exists,
//                var pet = try? document.data(as: Pet.self)
//
//            else { return }
//
//            pet.userIDs?.append(userID)
//
//            do {
//
//                try documentReference.setData(from: pet)
//
//            } catch {
//
//                completion(error)
//            }
//        }
//    }

//        db.collection(FirebaseCollectionType.favoritePet.rawValue)
//            .getDocuments { snapshot, error in
//
//            guard
//                let snapshot = snapshot else { return }
//
//            var pets = [Pet]()
//
//            for document in snapshot.documents {
//
//                do {
//                    let pet = try document.data(as: Pet.self)
//
//                    pets.append(pet)
//
//                } catch {
//
//                    completion(.failure(error))
//                }
//            }
//            completion(.success(pets))
//        }

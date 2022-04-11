//
//  PetFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/11.
//

import Foundation
import Firebase

class FavoritePetFirebaseManager {
    
    private enum FirebaseCollectionType: String {
        
        case favoritePet
    }
    
    static let shared = FavoritePetFirebaseManager()
    
    let db = Firestore.firestore()
    
    func fetchFavoritePet() {
        
        
        
    }
    
    func saveFavoritePet(userID: Int, with pet: Pet, completion: @escaping () -> Void) {
        
        // Check if there have existed same pet on firestore.
        
        let document = db.collection(FirebaseCollectionType.favoritePet.rawValue).document()
        
        
    }
    
//    func publishArticle(article: inout Article, completion: @escaping (Result<String, Error>) -> Void) {
//
//        let document = db.collection("articles").document()
//        article.id = document.documentID
//        article.createdTime = Date().millisecondsSince1970
//        document.setData(article.toDict) { error in
//
//            if let error = error {
//
//                completion(.failure(error))
//            } else {
//
//                completion(.success("Success"))
//            }
//        }
//    }
}

//
//  PetSocietyFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PetSocietyFirebaseManager {
    
    static let shared = PetSocietyFirebaseManager()
    
    let db = Firestore.firestore()
    
    func fetchArticle(completion: @escaping (Result<[Article], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.article.rawValue)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var articles = [Article]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let article = try document.data(as: Article.self, decoder: Firestore.Decoder())
                        
                        articles.append(article)
                    }
                    catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(articles))
            }
    }
    
    func publishArticle(_ userId: String, with article: inout Article, completion: @escaping (Error?) -> Void) {
        
        let documentReference = db.collection(FirebaseCollectionType.article.rawValue).document()
        
//        let documentId = documentReference.documentID
        
        do {
            
//            var article = articleViewModel.article
            
            article.userId = userId
            
            try documentReference.setData(from: article, encoder: Firestore.Encoder())
        }
        
        catch {
            
            completion(error)
        }
    }
}

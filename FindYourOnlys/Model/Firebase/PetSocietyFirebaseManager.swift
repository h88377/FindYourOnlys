//
//  PetSocietyFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

class PetSocietyFirebaseManager {
    
    static let shared = PetSocietyFirebaseManager()
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
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
        
        let documentId = documentReference.documentID
        
        do {
            
            article.userId = userId
            
            article.id = documentId
            
            article.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: article, encoder: Firestore.Encoder())
        }
        
        catch {
            
            completion(error)
        }
    }
    
    func fetchDownloadImageURL(image: UIImage, with articleId: String, completion: @escaping ((Result<URL, Error>) -> Void)) {
        
        let storageRef = storage.reference()
        
        let imageRef = storageRef.child("images/articles/\(articleId)")
        
        guard
            let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            
            guard
                error == nil
                    
            else {
                
                completion(.failure(error!))
                
                return
            }
            
            imageRef.downloadURL { url, error in
                guard
                    error == nil,
                    let url = url
                        
                else {
                    
                    completion(.failure(error!))
                    
                    return
                }
                
                completion(.success(url))
            }
            
        }
    }
}

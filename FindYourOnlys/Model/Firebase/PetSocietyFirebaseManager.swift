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
    
    // MARK: - Article
    func fetchArticle(completion: @escaping (Result<[Article], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.article.rawValue)
            .order(by: "createdTime", descending: true)
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
        
//        let storagePath = "\(your_firebase_storage_bucket)/images/space.jpg"
//        spaceRef = storage.reference(forURL: storagePath)
        
        let imageRef = storageRef.child("images/\(UserFirebaseManager.shared.currentUser)with time \(Date().timeIntervalSince1970).jpeg")
        
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
    
    // MARK: - ChatRoom
    func fetchChatRoom(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.chatRoom.rawValue)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var chatRooms = [ChatRoom]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let chatRoom = try document.data(as: ChatRoom.self)
                        
                        chatRooms.append(chatRoom)
                    }
                    catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(chatRooms))
            }
    }
    
//    func createThread(with thread: inout Thread, channelId: String, completion: @escaping (Error?) -> Void) {
//
//        let documentReference = db.collection(FirebaseCollectionType.thread.rawValue).document()
//
//        do {
//
//            thread.channelId = channelId
//
//            article.id = documentId
//
//            article.createdTime = NSDate().timeIntervalSince1970
//
//            try documentReference.setData(from: article, encoder: Firestore.Encoder())
//        }
//
//        catch {
//
//            completion(error)
//        }
//    }
    
    func fetchThread(with channelId: String, completion: @escaping (Result<[Thread], Error>) -> Void) {

        db.collection(FirebaseCollectionType.thread.rawValue)
            .addSnapshotListener { snapshot, error in

                guard
                    let snapshot = snapshot else { return }

                var threads = [Thread]()

                for document in snapshot.documents {

                    do {

                        let thread = try document.data(as: Thread.self)

                        threads.append(thread)
                    }
                    catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(threads))
            }
    }
}

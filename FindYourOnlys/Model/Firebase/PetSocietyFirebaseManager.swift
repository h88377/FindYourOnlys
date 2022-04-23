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
                        
                    } catch {
                        
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
    
    func fetchDownloadImageURL(image: UIImage, with type: String, completion: @escaping ((Result<URL, Error>) -> Void)) {
        
        let storageRef = storage.reference()
        
        //        let storagePath = "\(your_firebase_storage_bucket)/images/space.jpg"
        //        spaceRef = storage.reference(forURL: storagePath)
        
        let imageRef = storageRef.child("\(type)/\(UserFirebaseManager.shared.currentUser)with time \(Date().timeIntervalSince1970).jpeg")
        
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
            .order(by: "createdTime", descending: true)
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
    
    func fetchMessage(with channelId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.message.rawValue)
            .order(by: "createdTime", descending: false)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var messages = [Message]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let message = try document.data(as: Message.self)
                        
                        if message.chatRoomId == channelId {
                            
                            messages.append(message)
                        }
                    }
                    catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(messages))
            }
    }
    
    func sendMessage(_ senderId: String, with message: inout Message, completion: @escaping (Error?) -> Void) {
        
        let documentReference = db.collection(FirebaseCollectionType.message.rawValue).document()
        
        do {
            
            message.senderId = senderId
            
            message.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: message)
        }
        
        catch {
            
            completion(error)
        }
    }
    
    // MARK: - Friend
    
    func fetchFriendRequest(with userId: String, completion: @escaping (Result<[FriendRequest], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.friendRequest.rawValue)
            .order(by: "createdTime", descending: false)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var friendRequests = [FriendRequest]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let friendRequest = try document.data(as: FriendRequest.self)
                        
                        if friendRequest.requestUserId == userId || friendRequest.requestedUserId == userId {
                            
                            friendRequests.append(friendRequest)
                        }
                    }
                    catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(friendRequests))
            }
        
    }
    
    func sendFriendRequest(_ userId: String, with friendRequest: inout FriendRequest, completion: @escaping (Error?) -> Void) {
        
        let documentReference = db.collection(FirebaseCollectionType.friendRequest.rawValue).document()
        
        do {
            
            friendRequest.requestUserId = UserFirebaseManager.shared.currentUser
            
            friendRequest.requestedUserId = userId
            
            friendRequest.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: friendRequest)
        }
        
        catch {
            
            completion(error)
        }
    }
    
    
    
    // MARK: - Convert functions

    private func convertArticlesToViewModels(from articles: [Article]) -> [ArticleViewModel] {
        
        var viewModels = [ArticleViewModel]()
        
        for article in articles {
            
            let viewModel = ArticleViewModel(model: article)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }

    func setArticles(with viewModels: Box<[ArticleViewModel]>, articles: [Article]) {
        
        viewModels.value = convertArticlesToViewModels(from: articles)
    }
    
}



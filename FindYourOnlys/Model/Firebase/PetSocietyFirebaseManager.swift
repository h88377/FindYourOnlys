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

enum ArticleType: String {
    
    case missing = "協尋文章"
    
    case share = "分享文章"
}

class PetSocietyFirebaseManager {
    
    static let shared = PetSocietyFirebaseManager()
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    // MARK: - Article
    func fetchArticle(completion: @escaping (Result<[Article], Error>) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        db.collection(FirebaseCollectionType.article.rawValue)
//            .whereField("userId", isEqualTo: currentUser.id)
            .order(by: "createdTime", descending: true)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot
                        
                else {
                    
                    completion(.failure(error!))
                    
                    return
                }
                
                do {
                    
                    let articles = try snapshot.documents.map { try $0.data(as: Article.self)}
                    
                    completion(.success(articles))
                    
                } catch {
                    
                    completion(.failure(error))
                }
            }
    }
    
    func fetchArticle(articleType: ArticleType,
                      with condition: FindPetSocietyFilterCondition? = nil,
                      completion: @escaping (Result<[Article], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.article.rawValue)
            .order(by: "createdTime", descending: true)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot
                
                else {
                        
                        completion(.failure(error!))
                        
                        return
                        
                    }
                
                var articles = [Article]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let article = try document.data(as: Article.self)
                        
                        switch articleType {
                            
                        case .missing:
                            
                            switch condition == nil {
                                
                            case true:
                                
                                if article.postType != nil {
                                    
                                    articles.append(article)
                                }
                                
                            case false:
                                
                                // All conditions are filled in.
                                if article.postType == condition?.postType
                                    && article.petKind == condition?.petKind
                                    && article.city == condition?.city
                                    && article.color == condition?.color {
                                    
                                    articles.append(article)
                                }
                            }
                            
                        case .share:
                            
                            if article.postType == nil {
                                
                                articles.append(article)
                            }
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(articles))
            }
    }
    
    func fetchArticle(
        withArticleId id: String,
        completion: @escaping (Result<Article, Error>) -> Void) {
            
            db.collection(FirebaseCollectionType.article.rawValue)
                .whereField("id", isEqualTo: id)
                .addSnapshotListener { snapshot, error in
                
                    guard
                        let snapshot = snapshot
                            
                    else {
                        
                        completion(.failure(error!))
                        
                        return
                    }
                    do {
                        
                        let article = try snapshot.documents.map { try $0.data(as: Article.self) }[0]
                        
                        completion(.success(article))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
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
        } catch {
            
            completion(error)
        }
    }
    
    func deleteArticle(
        with userId: String,
        completion: @escaping (Error?) -> Void) {
            
            db.collection(FirebaseCollectionType.article.rawValue).getDocuments { snapshot, error in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(error)
                        
                        return
                    }
                
                for index in 0..<snapshot.documents.count {
                    
                    do {
                        
                        let deleteArticle = try snapshot.documents[index].data(as: Article.self)
                        
                        let currentUserId = UserFirebaseManager.shared.currentUser?.id
                        
                        if deleteArticle.userId == currentUserId {
                            
                            let docID = snapshot.documents[index].documentID
                            
                            self.db.collection(FirebaseCollectionType.article.rawValue).document("\(docID)").delete()
                        }
                    } catch {
                        
                        completion(error)
                    }
                    
                }
                
                completion(nil)
            }
        }
    
    func fetchDownloadImageURL(
        image: UIImage,
        with type: String,
        completion: @escaping ((Result<URL, Error>) -> Void)) {
            
            let storageRef = storage.reference()
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            let imageRef = storageRef.child(
                "\(type)/\(currentUser.id)with time \(Date().timeIntervalSince1970).jpeg"
            )
            
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
    
    func leaveComment(withArticle article: inout Article, comment: Comment, completion: @escaping (Error?) -> Void) {
        
        article.comments.append(comment)
        
        do {
            try db.collection(FirebaseCollectionType.article.rawValue).document(article.id).setData(from: article)
            
        } catch {
            
            completion(error)
        }
    }
    
    func likeArticle(with article: inout Article, completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        article.likeUserIds.append(currentUser.id)
        
        do {
            
            try db.collection(FirebaseCollectionType.article.rawValue).document(article.id).setData(from: article)
            
        } catch {
            
            completion(error)
        }
    }
    
    func unlikeArticle(with article: inout Article, completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        article.likeUserIds.removeAll { userId in
            
            let isRemove = userId == currentUser.id
            
            return isRemove
        }
        
        do {
            
            try db.collection(FirebaseCollectionType.article.rawValue).document(article.id).setData(from: article)
            
        } catch {
            
            completion(error)
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
    
    func deleteChatRoom(
        with userId: String,
        completion: @escaping (Error?) -> Void) {
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            db.collection(FirebaseCollectionType.chatRoom.rawValue).getDocuments { snapshot, error in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(error)
                        
                        return
                    }
                
                for index in 0..<snapshot.documents.count {
                    
                    do {
                        
                        let deleteChatRoom = try snapshot.documents[index].data(as: ChatRoom.self)
                        
                        if deleteChatRoom.userIds.contains(currentUser.id) {
                            
                            let docID = snapshot.documents[index].documentID
                            
                            self.db.collection(FirebaseCollectionType.chatRoom.rawValue).document("\(docID)").delete()
                        }
                    } catch {
                        
                        completion(error)
                    }
                    
                }
                
                completion(nil)
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
    
    func deleteMessage(
        with userId: String,
        completion: @escaping (Error?) -> Void) {
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            db.collection(FirebaseCollectionType.message.rawValue).getDocuments { snapshot, error in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(error)
                        
                        return
                    }
                
                for index in 0..<snapshot.documents.count {
                    
                    do {
                        
                        let deleteMessage = try snapshot.documents[index].data(as: Message.self)
                        
                        if deleteMessage.senderId == currentUser.id {
                            
                            let docID = snapshot.documents[index].documentID
                            
                            self.db.collection(FirebaseCollectionType.message.rawValue).document("\(docID)").delete()
                        }
                    } catch {
                        
                        completion(error)
                    }
                }
                completion(nil)
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
    
    func fetchFriendRequest(withRequest userId: String, completion: @escaping (Result<[FriendRequest], Error>) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        db.collection(FirebaseCollectionType.friendRequest.rawValue)
            .order(by: "createdTime", descending: false)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var friendRequests = [FriendRequest]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let friendRequest = try document.data(as: FriendRequest.self)
                        
                        if friendRequest.requestUserId == userId && friendRequest.requestedUserId == currentUser.id {
                            
                            friendRequests.append(friendRequest)
                            
                        } else if friendRequest.requestUserId == currentUser.id && friendRequest.requestedUserId == userId {
                            
                            friendRequests.append(friendRequest)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(friendRequests))
            }
        
    }
    
    func sendFriendRequest(_ userId: String, with friendRequest: inout FriendRequest, completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        let documentReference = db.collection(FirebaseCollectionType.friendRequest.rawValue).document()
        
        do {
            
            friendRequest.requestUserId = currentUser.id
            
            friendRequest.requestedUserId = userId
            
            friendRequest.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: friendRequest)
        }
        
        catch {
            
            completion(error)
        }
    }
    
    
    func deleteFriend(
        withCurrent userId: String,
        completion: @escaping (Error?) -> Void) {
            
            db.collection(FirebaseCollectionType.user.rawValue).whereField("friends", arrayContains: userId).getDocuments { snapshot, error in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(error)
                        
                        return
                    }
                
                do {

                    var users = try snapshot.documents.map { try $0.data(as: User.self) }
                    
                    for index in 0..<users.count {
                        
                        users[index].friends = users[index].friends.filter { $0 != userId }
                        
                        try self.db.collection(FirebaseCollectionType.user.rawValue).document(users[index].id).setData(from: users[index])
                    }
                    
                    completion(nil)

                } catch {

                    completion(error)
                }
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
    
    private func convertCommentsToViewModels(from comments: [Comment]) -> [CommentViewModel] {
        
        var viewModels = [CommentViewModel]()
        
        for comment in comments {
            
            let viewModel = CommentViewModel(model: comment)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setComments(with viewModels: Box<[CommentViewModel]>, comments: [Comment]) {
        
        viewModels.value = convertCommentsToViewModels(from: comments)
    }
    
    private func convertProfileArticlesToViewModels(from profileArticles: [ProfileArticle]) -> [ProfileArticleViewModel] {
        
        var viewModels = [ProfileArticleViewModel]()
        
        for profileArticle in profileArticles {
            
            let viewModel = ProfileArticleViewModel(model: profileArticle)
            
            viewModels.append(viewModel)
            
        }
        
        return viewModels
    }
    
    func setProfileArticles(with viewModels: Box<[ProfileArticleViewModel]>, profileArticles: [ProfileArticle]) {
        
        viewModels.value = convertProfileArticlesToViewModels(from: profileArticles)
    }
    
}



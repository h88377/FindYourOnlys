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
    
    case find = "協尋文章"
    
    case share = "分享文章"
}

class PetSocietyFirebaseManager {
    
    static let shared = PetSocietyFirebaseManager()
    
    private init() { }
    
    private let database = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    // MARK: - Article
    func fetchArticle(completion: @escaping (Result<[Article], Error>) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        database
            .collection(FirebaseCollectionType.article.rawValue)
            .whereField(FirebaseFieldType.userId.rawValue, isEqualTo: currentUser.id)
            .order(by: FirebaseFieldType.createdTime.rawValue, descending: true)
            .addSnapshotListener { snapshot, _ in
                
                guard
                    let snapshot = snapshot
                        
                else {
                    
                    completion(.failure(FirebaseError.fetchArticleError))
                    
                    return
                }
                
                do {
                    
                    let articles = try snapshot.documents.map { try $0.data(as: Article.self) }
                    
                    completion(.success(articles))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodeArticleError))
                }
            }
    }
    
    func fetchArticle(
        articleType: ArticleType,
        with condition: FindPetSocietyFilterCondition? = nil,
        completion: @escaping (Result<[Article], Error>) -> Void
    ) {
        database
            .collection(FirebaseCollectionType.article.rawValue)
            .order(by: FirebaseFieldType.createdTime.rawValue, descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                
                guard let snapshot = snapshot,
                      let self = self
                else {
                        
                    completion(.failure(FirebaseError.fetchArticleError))
                        
                        return
                    }
                
                var articles = [Article]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let article = try document.data(as: Article.self)
                        
                        switch articleType {
                            
                        case .find:
                            
                            if condition == nil {
                                
                                if article.postType != nil {
                                    
                                    self.append(articles: &articles, with: article)
                                }
                                
                            } else {
                                
                                // All conditions are filled in.
                                if article.postType == condition?.postType
                                    && article.petKind == condition?.petKind
                                    && article.city == condition?.city
                                    && article.color == condition?.color {
                                    
                                    self.append(articles: &articles, with: article)
                                }
                            }
                            
                        case .share:
                            
                            if article.postType == nil {
                                
                                self.append(articles: &articles, with: article)
                            }
                        }
                        
                    } catch {
                        
                        completion(.failure(FirebaseError.decodeArticleError))
                    }
                }
                
                completion(.success(articles))
            }
    }
    
    func fetchArticle(
        withArticleId id: String,
        completion: @escaping (Result<Article, Error>) -> Void
    ) {
        database.collection(FirebaseCollectionType.article.rawValue)
            .whereField(FirebaseFieldType.id.rawValue, isEqualTo: id)
            .addSnapshotListener { snapshot, _ in
                
                guard let snapshot = snapshot else {
                    
                    completion(.failure(FirebaseError.fetchArticleError))
                    
                    return
                }
                
                do {
                    
                    if snapshot.documents.count > 0 {
                        
                        let article = try snapshot.documents.map { try $0.data(as: Article.self) }[0]
                        
                        completion(.success(article))
                    }
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodeArticleError))
                }
            }
        }
    
    func publishArticle(
        _ userId: String,
        with article: inout Article,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        let documentReference = database.collection(FirebaseCollectionType.article.rawValue).document()
        
        let documentId = documentReference.documentID
        
        do {
            
            article.userId = userId
            
            article.id = documentId
            
            article.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: article)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.publishArticleError))
        }
    }
    
    func editArticle(
        with article: inout Article,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        let documentReference = database.collection(FirebaseCollectionType.article.rawValue).document(article.id)
        
        do {
            
            article.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: article)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.updateArticleError))
        }
    }
    
    func deleteArticle(
        with userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        database
            .collection(FirebaseCollectionType.article.rawValue)
            .getDocuments { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchArticleError))
                        
                        return
                    }
                
                for index in 0..<snapshot.documents.count {
                    
                    do {
                        
                        let deleteArticle = try snapshot.documents[index].data(as: Article.self)
                        
                        let currentUserId = UserFirebaseManager.shared.currentUser?.id
                        
                        if deleteArticle.userId == currentUserId {
                            
                            let docID = snapshot.documents[index].documentID
                            
                            self.database
                                .collection(FirebaseCollectionType.article.rawValue)
                                .document("\(docID)")
                                .delete()
                        }
                        
                    } catch {
                        
                        completion(.failure(FirebaseError.deleteArticleError))
                        
                        return
                    }
                }
                completion(.success(()))
            }
    }
    
    func deleteArticle(
        withArticleId articleId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        database
            .collection(FirebaseCollectionType.article.rawValue)
            .document(articleId).delete { error in
                
                guard error == nil else {
                    
                    completion(.failure(FirebaseError.deleteArticleError))
                    
                    return
                }
                
                completion(.success(()))
            }
    }
    
    func fetchDownloadImageURL(
        image: UIImage,
        with type: String,
        completion: @escaping ((Result<URL, Error>) -> Void)
    ) {
            let storageRef = storage.reference()
            
            guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            let imageRef = storageRef.child(
                "\(type)/\(currentUser.id)with time \(Date().timeIntervalSince1970).jpeg")
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                
                completion(.failure(FirebaseError.encodeImageError))
                
                return
            }
            
            imageRef.putData(imageData, metadata: nil) { _, error in
                
                guard error == nil else {
                    
                    completion(.failure(FirebaseError.uploadImageError))
                    
                    return
                }
                
                imageRef.downloadURL { url, error in
                    
                    guard
                        error == nil,
                        let url = url
                    else {
                        
                        completion(.failure(FirebaseError.fetchImageURLError))
                        
                        return
                    }
                    
                    completion(.success(url))
                }
            }
        }
    
    func leaveComment(
        withArticle article: inout Article,
        comment: Comment,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        article.comments.append(comment)
        
        do {
            try database
                .collection(FirebaseCollectionType.article.rawValue)
                .document(article.id)
                .setData(from: article)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.leaveCommentError))
        }
    }
    
    func likeArticle(
        with article: inout Article,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        article.likeUserIds.append(currentUser.id)
        
        do {
            
            try database
                .collection(FirebaseCollectionType.article.rawValue)
                .document(article.id)
                .setData(from: article)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.toggleLikeArticleError))
        }
    }
    
    func unlikeArticle(
        with article: inout Article,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        article.likeUserIds.removeAll { userId in
            
            let isRemove = userId == currentUser.id
            
            return isRemove
        }
        
        do {
            
            try database
                .collection(FirebaseCollectionType.article.rawValue)
                .document(article.id)
                .setData(from: article)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.toggleLikeArticleError))
        }
    }
    
    // MARK: - ChatRoom
    func fetchChatRoom(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        
        database.collection(FirebaseCollectionType.chatRoom.rawValue)
            .order(by: FirebaseFieldType.createdTime.rawValue, descending: true)
            .addSnapshotListener { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchChatRoomError))
                        
                        return
                    }
                
                do {
                    
                    let chatRooms = try snapshot.documents.map { try $0.data(as: ChatRoom.self) }
                    
                    completion(.success(chatRooms))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.fetchChatRoomError))
                }
            }
    }
    
    func deleteChatRoom(
        with userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
            guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            database
            .collection(FirebaseCollectionType.chatRoom.rawValue)
            .getDocuments { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchChatRoomError))
                        
                        return
                    }
                
                for index in 0..<snapshot.documents.count {
                    
                    do {
                        
                        let deleteChatRoom = try snapshot.documents[index].data(as: ChatRoom.self)
                        
                        if deleteChatRoom.userIds.contains(currentUser.id) {
                            
                            let docID = snapshot.documents[index].documentID
                            
                            self.database
                                .collection(FirebaseCollectionType.chatRoom.rawValue)
                                .document("\(docID)")
                                .delete()
                        }
                        
                    } catch {
                        
                        completion(.failure(FirebaseError.deleteChatRoomError))
                        
                        return
                    }
                }
                completion(.success(()))
            }
        }
    
    func fetchMessage(
        with channelId: String,
        completion: @escaping (Result<[Message], Error>) -> Void
    ) {
        database
            .collection(FirebaseCollectionType.message.rawValue)
            .order(by: FirebaseFieldType.createdTime.rawValue, descending: false)
            .addSnapshotListener { snapshot, _ in
                
                guard let snapshot = snapshot else {
                    
                    completion(.failure(FirebaseError.fetchMessageError))
                    
                    return
                }
                
                do {
                    
                    let messages = try snapshot.documents
                        .map { try $0.data(as: Message.self) }
                        .filter { $0.chatRoomId == channelId }
                    
                    completion(.success(messages))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.fetchMessageError))
                }
            }
    }
    
    func deleteMessage(
        with userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
            guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            database
            .collection(FirebaseCollectionType.message.rawValue)
            .getDocuments { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchMessageError))
                        
                        return
                    }
                
                for index in 0..<snapshot.documents.count {
                    
                    do {
                        
                        let deleteMessage = try snapshot.documents[index].data(as: Message.self)
                        
                        if deleteMessage.senderId == currentUser.id {
                            
                            let docID = snapshot.documents[index].documentID
                            
                            self.database
                                .collection(FirebaseCollectionType.message.rawValue)
                                .document("\(docID)")
                                .delete()
                        }
                        
                    } catch {
                        
                        completion(.failure(FirebaseError.deleteMessageError))
                        
                        return
                    }
                }
                completion(.success(()))
            }
        }
    
    func sendMessage(
        _ senderId: String,
        with message: inout Message,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let documentReference = database.collection(FirebaseCollectionType.message.rawValue).document()
        
        do {
            
            message.senderId = senderId
            
            message.createdTime = NSDate().timeIntervalSince1970
            
            try documentReference.setData(from: message)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.sendMessageError))
        }
    }
    
    // MARK: - Friend
    
    func fetchFriendRequest(
        with userId: String,
        completion: @escaping (Result<[FriendRequest], Error>) -> Void
    ) {
        database
            .collection(FirebaseCollectionType.friendRequest.rawValue)
            .order(by: FirebaseFieldType.createdTime.rawValue, descending: false)
            .addSnapshotListener { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchFriendRequestError))
                        
                        return
                    }
                
                do {
                    
                    let friendRequests = try snapshot.documents
                        .map { try $0.data(as: FriendRequest.self) }
                        .filter { $0.requestUserId == userId || $0.requestedUserId == userId }
                    
                    completion(.success(friendRequests))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodeFriendRequestError))
                }
            }
        
    }
    
    func fetchFriendRequest(
        withRequest userId: String,
        completion: @escaping (Result<[FriendRequest], Error>) -> Void
    ) {
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        database.collection(FirebaseCollectionType.friendRequest.rawValue)
            .order(by: FirebaseFieldType.createdTime.rawValue, descending: false)
            .getDocuments { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchFriendRequestError))
                        
                        return
                    }
                
                do {
                    
                    let friendRequests = try snapshot.documents
                        .map { try $0.data(as: FriendRequest.self) }
                        .filter {
                            
                            let isRequester = $0.requestUserId == userId && $0.requestedUserId == currentUser.id
                            
                            let isSender = $0.requestUserId == currentUser.id && $0.requestedUserId == userId
                            
                            return isRequester || isSender
                        }
                    
                    completion(.success(friendRequests))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodeFriendRequestError))
                }
            }
    }
    
    func sendFriendRequest(
        _ userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        let documentReference = database.collection(FirebaseCollectionType.friendRequest.rawValue).document()
        
        do {
            
            let friendRequest = FriendRequest(
                requestUserId: currentUser.id,
                requestedUserId: userId,
                createdTime: NSDate().timeIntervalSince1970
            )
            
            try documentReference.setData(from: friendRequest)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.sendFriendRequestError))
        }
    }
    
    func deleteFriend(
        withCurrent userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
            database
            .collection(FirebaseCollectionType.user.rawValue)
            .whereField(FirebaseFieldType.friends.rawValue, arrayContains: userId)
            .getDocuments { snapshot, _ in
                
                guard let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchUserError))
                        
                        return
                    }
                
                do {
                    
                    var users = try snapshot.documents.map { try $0.data(as: User.self) }
                    
                    for index in 0..<users.count {
                        
                        users[index].friends = users[index].friends.filter { $0 != userId }
                        
                        try self.database
                            .collection(FirebaseCollectionType.user.rawValue)
                            .document(users[index].id)
                            .setData(from: users[index])
                    }
                    
                    completion(.success(()))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.deleteUserError))
                }
            }
    }
    
    private func append(articles: inout [Article], with article: Article) {
        
        if let currentUser = UserFirebaseManager.shared.currentUser {
            
            let isBlock = currentUser.blockedUsers.contains(article.userId)
            
            if !isBlock {
                
                articles.append(article)
            }
            
        } else {
            
            articles.append(article)
        }
    }
    
    // MARK: - Convert functions
    
    private func convertArticlesToViewModels(from articles: [Article]) -> [ArticleViewModel] {
        
        let viewModels = articles.map { ArticleViewModel(model: $0) }
        
        return viewModels
    }
    
    func setArticles(with viewModels: Box<[ArticleViewModel]>, articles: [Article]) {
        
        viewModels.value = convertArticlesToViewModels(from: articles)
    }
    
    private func convertCommentsToViewModels(from comments: [Comment]) -> [CommentViewModel] {
        
        let viewModels = comments.map { CommentViewModel(model: $0) }
        
        return viewModels
    }
    
    func setComments(with viewModels: Box<[CommentViewModel]>, comments: [Comment]) {
        
        viewModels.value = convertCommentsToViewModels(from: comments)
    }
}

//
//  ProfileFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ProfileFirebaseManager {
    
    static let shared = ProfileFirebaseManager()
    
    private let db = Firestore.firestore()
    
    func removeFriendRequest(
        with viewModels: [FriendRequestListViewModel],
        at indexPath: IndexPath, completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.friendRequest.rawValue).getDocuments { snapshot, error in
            
            guard
                let snapshot = snapshot else {
                    
                    completion(.failure(FirebaseError.fetchFriendRequestError))
                    
                    return
                    
                }
            
            for index in 0..<snapshot.documents.count {
                
                do {
                    
                    let removeRequest = try snapshot.documents[index].data(as: FriendRequest.self)
                    
                    let currentUserId = UserFirebaseManager.shared.currentUser?.id
                    
                    let requestUserId = viewModels[indexPath.section].friendRequestList.users[indexPath.row].id
                    
                    if removeRequest.requestedUserId == currentUserId && removeRequest.requestUserId == requestUserId {
                        
                        let docID = snapshot.documents[index].documentID
                        
                        self.db.collection(FirebaseCollectionType.friendRequest.rawValue).document("\(docID)").delete()
                    }
                    
                } catch {
                    
                    completion(.failure(FirebaseError.deleteFriendRequestError))
                    
                    return
                }
            }
            
            completion(.success("success"))
        }
    }
    
    func removeFriendRequest(
        with userId: String,
        completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.friendRequest.rawValue).getDocuments { snapshot, error in
            
            guard
                let snapshot = snapshot else {
                    
                    completion(.failure(FirebaseError.fetchFriendRequestError))
                    
                    return
                }
            
            for index in 0..<snapshot.documents.count {
                
                do {
                    
                    let removeRequest = try snapshot.documents[index].data(as: FriendRequest.self)
                    
                    let currentUserId = UserFirebaseManager.shared.currentUser?.id
                    
                    if removeRequest.requestedUserId == currentUserId || removeRequest.requestUserId == currentUserId {
                        
                        let docID = snapshot.documents[index].documentID
                        
                        self.db.collection(FirebaseCollectionType.friendRequest.rawValue).document("\(docID)").delete()
                    }
                } catch {
                    
                    completion(.failure(FirebaseError.deleteFriendRequestError))
                }
                
            }
            
            completion(.success("success"))
        }
    }
    
    func addFriendRequest(with viewModels: [FriendRequestListViewModel], at indexPath: IndexPath, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        var requestUser = viewModels[indexPath.section].friendRequestList.users[indexPath.row]
        
        var requestedUser = currentUser
        
        requestUser.friends.append(requestedUser.id)
        
        requestedUser.friends.append(requestUser.id)
        
        do {
            try db.collection(FirebaseCollectionType.user.rawValue).document(requestUser.id).setData(from: requestUser)
            
            try db.collection(FirebaseCollectionType.user.rawValue).document(requestedUser.id).setData(from: requestedUser)
            
            completion(.success("success"))
            
        } catch {
            
            completion(.failure(FirebaseError.addFriendRequestError))
        }
    }
    
    func createChatRoom(with viewModels: [FriendRequestListViewModel], at indexPath: IndexPath, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        let documentReference = db.collection(FirebaseCollectionType.chatRoom.rawValue).document()
        
        let requestUser = viewModels[indexPath.section].friendRequestList.users[indexPath.row]
        
        let requestedUser = currentUser
        
        do {
            
            let userIds = [requestUser.id, requestedUser.id]
            
            let chatRoom = ChatRoom(
                id: documentReference.documentID,
                userIds: userIds,
                createdTime: NSDate().timeIntervalSince1970
            )
            
            try documentReference.setData(from: chatRoom)
            
            completion(.success("success"))
        }
        
        catch {
            
            completion(.failure(FirebaseError.createChatRoomError))
        }
    }
    
    // MARK: - convert functions
    private func convertFriendRequestListsToViewModels(from requests: [FriendRequestList]) -> [FriendRequestListViewModel] {
        
        var viewModels = [FriendRequestListViewModel]()
        
        for request in requests {
            
            let viewModel = FriendRequestListViewModel(model: request)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setFriendRequestLists(with viewModels: Box<[FriendRequestListViewModel]>, requests: [FriendRequestList]) {
        
        viewModels.value = convertFriendRequestListsToViewModels(from: requests)
    }
}

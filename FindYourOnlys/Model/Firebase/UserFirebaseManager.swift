//
//  UserManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import Firebase

class UserFirebaseManager {
    
    static let shared = UserFirebaseManager()
    
    private let db = Firestore.firestore()
    
    var currentUser: String { return "321" }
    
    var currentUserImageURL: String { return "https://firebasestorage.googleapis.com:443/v0/b/findyouronlys.appspot.com/o/images%2F123.jpeg?alt=media&token=fdac6ab2-47e1-4f9a-b5f2-20c464e7f911" }
    
    func fetchUser(completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.user.rawValue)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var users = [User]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let user = try document.data(as: User.self)
                        
                        users.append(user)
                    }
                    catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(users))
            }
    }
}

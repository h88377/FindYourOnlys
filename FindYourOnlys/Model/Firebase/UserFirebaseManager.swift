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
    
    var currentUser: String { return "123" }
    
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

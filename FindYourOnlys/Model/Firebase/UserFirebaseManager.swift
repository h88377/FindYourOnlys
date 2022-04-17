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
    
    var currentUserImageURL: String { return "https://firebasestorage.googleapis.com:443/v0/b/findyouronlys.appspot.com/o/images%2F123.jpeg?alt=media&token=fdac6ab2-47e1-4f9a-b5f2-20c464e7f911" }
    
    var currentUserInfo: User {

        return User(id: "123", nickName: "Wayne", email: "123@email", imageURLString: "",
                    friends: ["321", "456", "654"], limitedUsers: ["444"])
    }
    
//    var currentUserInfo: User {
//
//        return User(id: "321", nickName: "Luke", email: "321@email", imageURLString: "",
//                    friends: ["123"], limitedUsers: ["444"])
//    }
    
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
    
    // MARK: - Convert functions
    private func convertUserToViewModels(from users: [User]) -> [UserViewModel] {
        
        var viewModels = [UserViewModel]()
        
        for user in users {
            
            let viewModel = UserViewModel(model: user)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setUsers(with viewModels: Box<[UserViewModel]>, users: [User]) {
        
        viewModels.value = UserFirebaseManager.shared.convertUserToViewModels(from: users)
    }
}

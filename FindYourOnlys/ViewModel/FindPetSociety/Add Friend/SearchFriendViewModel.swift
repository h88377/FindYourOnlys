//
//  SearchFriendViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import Foundation

class SearchFriendViewModel {
    
//    var searchUserIdHandler: (() -> Void)?
    
    var user = User(
        id: "", nickName: "", email: "",
        imageURLString: "", friends: [], limitedUsers: []
    )
    
    var friendRequest = FriendRequest(
        requestUserId: "", requestedUserId: "", createdTime: -1
    )
    
    func searchUserId(with userId: String, completion: @escaping (Result<SearchFriendResult, Error>) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        UserFirebaseManager.shared.fetchUser(with: userId) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                if users.count == 0 {
                    
                    completion(.success(.noRelativeId))
                }
                
                for user in users {
                    
                    if user.id == userId {
                        
                        if currentUser.friends.contains(userId) {
                            
                            completion(.success(.friend))
                            
                        } else if currentUser.limitedUsers.contains(userId) {
                            
                            completion(.success(.limitedUser))
                            
                        } else if userId  == currentUser.id {
                            
                            completion(.success(.currentUser))
                            
                        } else {
                            
                            PetSocietyFirebaseManager.shared.fetchFriendRequest(withRequest: userId) { result in
                                
                                switch result {
                                    
                                case .success(let requests):
                                    
                                    if requests.count == 0 {
                                        
                                        completion(.success(.normalUser))
                                    }
                                    
                                    for request in requests {
                                        
                                        if request.requestUserId == userId {
                                            
                                            completion(.success(.sentRequest))
                                            
                                        } else if request.requestedUserId == userId {
                                            
                                            completion(.success(.receivedRequest))
                                        }
                                    }
                                    
                                case .failure(let error):
                                    
                                    completion(.failure(error))
                                }
                            }
                        }
                        
                        self?.user = user
                        
                        break
                    }
                    completion(.success(.noRelativeId))
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
}

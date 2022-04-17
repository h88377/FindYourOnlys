//
//  SearchFriendViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import Foundation
import SwiftUI

class SearchFriendViewModel {
    
//    var searchUserIdHandler: (() -> Void)?
    
    var user = User(
        id: "", nickName: "", email: "",
        imageURLString: "", friends: [], limitedUsers: []
    )
    
    func searchUserId(with userId: String, completion: @escaping (Result<SearchFriendResult, Error>) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                for user in users {
                    
                    if user.id == userId {
                        
                        if UserFirebaseManager.shared.currentUserInfo.friends.contains(userId) {
                            
                            completion(.success(.friend))
                            
                        } else if UserFirebaseManager.shared.currentUserInfo.limitedUsers.contains (userId){
                            
                            completion(.success(.limitedUser))
                            
                        } else {
                            
                            PetSocietyFirebaseManager.shared.fetchFriendRequest(with: userId) { result in
                                
                                switch result {
                                    
                                case .success(let requests):
                                    
                                    for request in requests {
                                        
                                        if request.requestUserId == userId {
                                            
                                            completion(.success(.sentRequest))
                                            
                                        } else if request.reqeustedUserId == userId {
                                            
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

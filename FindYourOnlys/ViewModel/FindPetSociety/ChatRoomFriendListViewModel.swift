//
//  FriendListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import Foundation

class ChatRoomFriendListViewModel {
    
    let chatRoomViewModels = Box([ChatRoomViewModel]())
    
    let friendViewModels = Box([UserViewModel]())
    
    private func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { result in
            
            switch result {
                
            case .success(let users):
                
                for user in users {
                    
                    if user.id == UserFirebaseManager.shared.currentUser {
                        
                        completion(.success(user))
                        
                        break
                    }
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func fetchChatRoom(completion: @escaping (Error?)-> Void) {
        
        fetchUser { result in
            
            switch result {
                
            case .success(let user):
                
                PetSocietyFirebaseManager.shared.fetchChatRoom { [weak self] result in
                    
                    switch result {
                        
                    case .success(let totalChatRooms):
                        
                        let currentChatRooms = totalChatRooms.filter {
                            
                            $0.userIds.contains {
                                
                                $0 == UserFirebaseManager.shared.currentUser
                            }
                        }
                        
                        self?.setChatRooms(currentChatRooms)
                        
                    case .failure(let error):
                        
                        completion(error)
                    }
                }
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
    }
    
    private func convertChatRoomToViewModels(from chatRooms: [ChatRoom]) -> [ChatRoomViewModel] {
        
        var viewModels = [ChatRoomViewModel]()
        
        for chatRoom in chatRooms {
            
            let viewModel = ChatRoomViewModel(model: chatRoom)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    private func setChatRooms(_ chatRooms: [ChatRoom]) {
        
        chatRoomViewModels.value = convertChatRoomToViewModels(from: chatRooms)
    }
    
}

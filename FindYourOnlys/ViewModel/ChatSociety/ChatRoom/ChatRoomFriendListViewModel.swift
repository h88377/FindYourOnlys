//
//  FriendListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import Foundation

class ChatRoomFriendListViewModel {
    
    // MARK: - Properties
    
    // No need to be Box?
    let chatRoomViewModels = Box([ChatRoomViewModel]())
    
    let friendViewModels = Box([UserViewModel]())
    
    let errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    // MARK: - Methods
    
    func fetchChatRoom() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        fetchUser(with: currentUser.id ) { result in
            
            switch result {
                
            case .success(let user):
                
                PetSocietyFirebaseManager.shared.fetchChatRoom { [weak self] result in
                    
                    guard
                        let self = self else { return }
                    
                    switch result {
                        
                    case .success(let totalChatRooms):
             
                        var currentChatRooms = [ChatRoom]()
                        
                        var friendIds = [String]()
                        
                        for chatRoom in totalChatRooms {
                            
                            for userId in chatRoom.userIds where userId == currentUser.id {
                                
                                currentChatRooms.append(chatRoom)
                                
                                for friendId in chatRoom.userIds where friendId != currentUser.id {
                                    
                                    friendIds.append(friendId)
                                }
                            }
                        }
                        
                        self.setChatRooms(currentChatRooms)
                        
                        self.fetchUsers(with: friendIds) { result in
                            
                            switch result {
                                
                            case .success(let users):
                                
                                var orderedUsers = [User]()
                                
                                for friendId in friendIds {
                                    
                                    for user in users {
                                        
                                        if user.id == friendId {
                                            
                                            orderedUsers.append(user)
                                        }
                                    }
                                }
                                UserFirebaseManager.shared.setUsers(with: self.friendViewModels, users: orderedUsers)
                                
                            case .failure(let error):
                                
                                self.errorViewModel.value = ErrorViewModel(model: error)
                            }
                        }
                        
                    case .failure(let error):
                        
                        self.errorViewModel.value = ErrorViewModel(model: error)
                    }
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
        
    }
    
    private func fetchUser(with userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { result in
            
            switch result {
                
            case .success(let users):
                
                for user in users where user.id == userId {
                    
                    completion(.success(user))
                    
                    break
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    private func fetchUsers(with userIds: [String], completion: @escaping (Result<[User], Error>) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { result in
            
            switch result {
                
            case .success(let users):
                
                var fetchedUsers = [User]()
                
                for user in users {
                    
                    for userId in userIds where userId == user.id {
                        
                        fetchedUsers.append(user)
                    }
                    
                    completion(.success(fetchedUsers))
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Convert functions
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

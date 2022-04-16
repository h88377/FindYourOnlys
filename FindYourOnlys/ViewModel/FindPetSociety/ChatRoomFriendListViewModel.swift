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
    
//    var selected
    
    var didSelecteRowHandler: (() -> Void)?
    
    func didSelectRowAtTableView() {
        
        didSelecteRowHandler?()
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
    
    func fetchChatRoom(completion: @escaping (Error?)-> Void) {
        
        fetchUser(with: UserFirebaseManager.shared.currentUser ) { result in
            
            switch result {
                
            case .success(let user):
                
                PetSocietyFirebaseManager.shared.fetchChatRoom { [weak self] result in
                    
                    switch result {
                        
                    case .success(let totalChatRooms):
             
                        var currentChatRooms = [ChatRoom]()
                        
                        var friendIds = [String]()
                        
                        for chatRoom in totalChatRooms {
                            
                            for userId in chatRoom.userIds where userId == UserFirebaseManager.shared.currentUser {
                                
                                currentChatRooms.append(chatRoom)
                                
                                for friendId in chatRoom.userIds where friendId != UserFirebaseManager.shared.currentUser {
                                    
                                    friendIds.append(friendId)
                                }
                            }
                        }
                        
                        self?.setChatRooms(currentChatRooms)
                        
                        self?.fetchUsers(with: friendIds) { result in
                            
                            switch result {
                                
                            case .success(let users):
                                
                                self?.setUsers(users)
                                
                            case .failure(let error):
                                
                                completion(error)
                            }
                        }
                        
                    case .failure(let error):
                        
                        completion(error)
                    }
                }
                
            case .failure(let error):
                
                completion(error)
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
    
    private func convertUserToViewModels(from users: [User]) -> [UserViewModel] {
        
        var viewModels = [UserViewModel]()
        
        for user in users {
            
            let viewModel = UserViewModel(model: user)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    private func setUsers(_ users: [User]) {
        
        friendViewModels.value = convertUserToViewModels(from: users)
    }
    
}

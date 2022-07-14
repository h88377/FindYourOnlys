//
//  FriendListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import Foundation

class ChatRoomFriendListViewModel {
    
    // MARK: - Properties
    
    let chatRoomViewModels = Box([ChatRoomViewModel]())
    
    let friendViewModels = Box([UserViewModel]())
    
    let errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    // MARK: - Methods
    
    func fetchChatRoom() {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        PetSocietyFirebaseManager.shared.fetchChatRoom { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let totalChatRooms):
                
                let currentChatRooms = totalChatRooms.filter { $0.userIds.contains(currentUser.id) }
                
                let friendIds = currentChatRooms
                    .flatMap { $0.userIds }
                    .filter { $0 != currentUser.id }
                
                self.chatRoomViewModels.value = currentChatRooms.map { ChatRoomViewModel(model: $0) }
                
                self.fetchFriends(with: friendIds) { result in
                    
                    switch result {
                        
                    case .success(let users):
                        
                        let chatRoomFriends = self.reorderFriends(users: users, withIds: friendIds)
                        
                        UserFirebaseManager.shared.setUsers(with: self.friendViewModels, users: chatRoomFriends)
                        
                    case .failure(let error):
                        
                        self.errorViewModel.value = ErrorViewModel(model: error)
                    }
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchFriends(with friendIds: [String], completion: @escaping (Result<[User], Error>) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { result in
            
            switch result {
                
            case .success(let users):
                
                var fetchFriends = [User]()
                
                for user in users {
                    
                    for friendId in friendIds where friendId == user.id {
                        
                        fetchFriends.append(user)
                    }
                }
                completion(.success(fetchFriends))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    private func reorderFriends(users: [User], withIds ids: [String]) -> [User] {
        
        var chatRoomFriends = [User]()

        for id in ids {

            for user in users where user.id == id {

                chatRoomFriends.append(user)
            }
        }
        
        return chatRoomFriends
    }
}

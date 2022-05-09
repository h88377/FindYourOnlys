//
//  FriendRequestViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import Foundation

enum FriendRequestType: String, CaseIterable {
    
    case requested = "待接受"
    
    case request = "待同意"
}

class FriendRequestViewModel {
    
    var friendRequestListViewModels = Box([FriendRequestListViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    func fetchFriendRequestList() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        PetSocietyFirebaseManager.shared.fetchFriendRequest(with: currentUser.id) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let requests):
                
                var requestList = FriendRequestList(type: .request, users: [])
                
                var requestUsers: [String] = []
                
                var requestedList = FriendRequestList(type: .requested, users: [])
                
                var requestedUsers: [String] = []
                
                for request in requests {
                    
                    if request.requestUserId == currentUser.id {
                        
                        requestUsers.append(request.requestedUserId)
                    }
                    
                    if request.requestedUserId == currentUser.id {
                        
                        let isBlocked = currentUser.blockedUsers.contains(request.requestUserId)
                        
                        if !isBlocked {
                         
                            requestedUsers.append(request.requestUserId)
                        }
                    }
                }
                
                UserFirebaseManager.shared.fetchUser { result in
                    
                    switch result {
                        
                    case .success(let users):
                        
                        for user in users {
                            
                            for requestUser in requestUsers where requestUser == user.id {
                                
                                requestList.users.append(user)
                            }
                            
                            for requestedUser in requestedUsers where requestedUser == user.id {
                                
                                requestedList.users.append(user)
                            }
                        }
                        
                        ProfileFirebaseManager.shared.setFriendRequestLists(with: self.friendRequestListViewModels, requests: [requestList, requestedList])
                        
                    case .failure(let error):
                        
                        self.errorViewModel.value = ErrorViewModel(model: error)
                    }
                    
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
        
    }
    
    func acceptFriendRequest(at indexPath: IndexPath) {
        
        // Remove friend request
        removeFriendRequest(at: indexPath)
        
        // Add friend into each user's friend array
        ProfileFirebaseManager.shared.addFriendRequest(with: friendRequestListViewModels.value, at: indexPath) { result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
        
        // Create chatroom (including created time)
        ProfileFirebaseManager.shared.createChatRoom(with: friendRequestListViewModels.value, at: indexPath) { result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func removeFriendRequest(at indexPath: IndexPath) {
        
        // Remove friend request
        ProfileFirebaseManager.shared.removeFriendRequest(with: friendRequestListViewModels.value, at: indexPath) { result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    
}

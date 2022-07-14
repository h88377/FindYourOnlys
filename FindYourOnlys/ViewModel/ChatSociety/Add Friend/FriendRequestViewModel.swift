//
//  FriendRequestViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import Foundation

enum FriendRequestType: String, CaseIterable {
    
    case requested = "待本人接受"
    
    case request = "待對方接受"
}

class FriendRequestViewModel {
    
    // MARK: - Properties
    
    var friendRequestListViewModels = Box([FriendRequestListViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    func fetchFriendRequestList() {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        PetSocietyFirebaseManager.shared.fetchFriendRequest(with: currentUser.id) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let requests):
                
                // Invitation that wait other users accept
                let requestUserIds = self.getRequestUserIds(with: requests)
                
                // Invitation that wait current user accept
                let requestedUserIds = self.getRequestedUserIds(with: requests)
                
                UserFirebaseManager.shared.fetchUser { result in
                    
                    switch result {
                        
                    case .success(let users):
                        
                        let requestUsers = users.filter { requestUserIds.contains($0.id) }
                        
                        let requestedUsers = users.filter { requestedUserIds.contains($0.id) }
                        
                        let requestList = FriendRequestList(type: .request, users: requestUsers)
                        
                        let requestedList = FriendRequestList(type: .requested, users: requestedUsers)
                        
                        self.friendRequestListViewModels.value = [requestList, requestedList]
                            .map { FriendRequestListViewModel(model: $0) }
                        
                    case .failure(let error):
                        
                        self.errorViewModel.value = ErrorViewModel(model: error)
                    }
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func getRequestUserIds(with requests: [FriendRequest]) -> [String] {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return [] }
        
        let requestUserIds = requests
            .filter { $0.requestUserId == currentUser.id }
            .map { $0.requestedUserId }
        
        return requestUserIds
    }
    
    private func getRequestedUserIds(with requests: [FriendRequest]) -> [String] {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return [] }
        
        let requestedUserIds = requests
            .filter {
                
                let isRequested = $0.requestedUserId == currentUser.id
                
                let isBlocked = currentUser.blockedUsers.contains($0.requestedUserId)
                
                return isRequested && !isBlocked
                
            }.map { $0.requestUserId }
        
        return requestedUserIds
    }
    
    func acceptFriendRequest(at indexPath: IndexPath) {
        
        // Remove friend request
        removeFriendRequest(at: indexPath)
        
        // Add friend into each user's friend array
        ProfileFirebaseManager.shared.addFriendRequest(
            with: friendRequestListViewModels.value,
            at: indexPath
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
        
        // Create chatroom (including created time)
        ProfileFirebaseManager.shared.createChatRoom(
            with: friendRequestListViewModels.value,
            at: indexPath
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func removeFriendRequest(at indexPath: IndexPath) {
        
        // Remove friend request
        ProfileFirebaseManager.shared.removeFriendRequest(
            with: friendRequestListViewModels.value,
            at: indexPath
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}

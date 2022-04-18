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

class ProfileFriendRequestViewModel {
    
    var friendRequestListViewModels = Box([FriendRequestListViewModel]())
    
    var errorViewModel: Box<ErrorViewModel>?
    
    func fetchFriendRequest() {
        
        PetSocietyFirebaseManager.shared.fetchFriendRequest(with: UserFirebaseManager.shared.currentUserInfo.id) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let requests):
                
                var requestList = FriendRequestList(type: .request, users: [])
                
                var requestUsers: [String] = []
                
                var requestedList = FriendRequestList(type: .requested, users: [])
                
                var requestedUsers: [String] = []
                
                for request in requests {
                    
                    if request.requestUserId == UserFirebaseManager.shared.currentUserInfo.id {
                        
                        requestUsers.append(request.requestedUserId)
                    }
                    
                    if request.requestedUserId == UserFirebaseManager.shared.currentUserInfo.id {
                        
                        requestedUsers.append(request.requestUserId)
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
                        
                        self.errorViewModel = Box(ErrorViewModel(model: error))
                    }
                    
                }
                
            case .failure(let error):
                
                self.errorViewModel = Box(ErrorViewModel(model: error))
            }
        }
        
    }
    
}

//
//  SearchFriendViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import Foundation

class SearchFriendViewModel {
    
    // MARK: - Properties
    
    var searchViewModel: Box<SearchViewModel?> = Box(nil)
    
    var error: Box<Error?> = Box(nil)
    
    var userEmail: String?
    
    // MARK: - Methods
    
    func changedUserEmail(with email: String) {
        
        userEmail = email
    }
    
    func searchUserEmail() {
        
        guard let userEmail = userEmail else { return }
        
        UserFirebaseManager.shared.fetchUser(with: userEmail) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                if users.isEmpty {
                    
                    self.searchViewModel.value = SearchViewModel(searchResult: .noRelativeEmail)
                }
                
                self.checkSearchResult(by: userEmail, in: users)
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func checkSearchResult(by userEmail: String, in users: [User]) {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        for user in users where user.email == userEmail {
            
            switch user {
                
            case let blockedUser where currentUser.blockedUsers.contains(blockedUser.id):
                
                self.searchViewModel.value = SearchViewModel(user: blockedUser, searchResult: .blockedUser)
                
            case let friend where currentUser.friends.contains(friend.id):
                
                self.searchViewModel.value = SearchViewModel(user: friend, searchResult: .friend)
                
            case let selfUser where currentUser.id == selfUser.id:
                
                self.searchViewModel.value = SearchViewModel(user: selfUser, searchResult: .currentUser)
                
            default:
                
                checkFriendRequest(with: user)
            }
        }
    }
    
    private func checkFriendRequest(with user: User) {
        
        PetSocietyFirebaseManager.shared.fetchFriendRequest(withRequest: user.id) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let requests):
                
                if requests.isEmpty {
                    
                    self.searchViewModel.value = SearchViewModel(user: user, searchResult: .normalUser)
                }
                
                for request in requests {
                    
                    if request.requestUserId == user.id {
                        
                        self.searchViewModel.value = SearchViewModel(user: user, searchResult: .receivedRequest)
                        
                    } else if request.requestedUserId == user.id {
                        
                        self.searchViewModel.value = SearchViewModel(user: user, searchResult: .sentRequest)
                    }
                }
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
}

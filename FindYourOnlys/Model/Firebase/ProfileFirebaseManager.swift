//
//  ProfileFirebaseManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ProfileFirebaseManager {
    
    static let shared = ProfileFirebaseManager()
    
    private let db = Firestore.firestore()
    
    // MARK: - convert functions
    private func convertFriendRequestListsToViewModels(from requests: [FriendRequestList]) -> [FriendRequestListViewModel] {
        
        var viewModels = [FriendRequestListViewModel]()
        
        for request in requests {
            
            let viewModel = FriendRequestListViewModel(model: request)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }

    func setFriendRequestLists(with viewModels: Box<[FriendRequestListViewModel]>, requests: [FriendRequestList]) {
        
        viewModels.value = convertFriendRequestListsToViewModels(from: requests)
    }
}

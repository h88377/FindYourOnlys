//
//  ChatRoomThreadViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import Foundation

class ChatRoomThreadViewModel {
    
    let threadViewModels = Box([ThreadViewModel]())
    
    private var selectedChatRoomId: String?
    
    var selectedFriendURLString: String?
    
    func fetchThread(completion: @escaping (Error?) -> Void) {
        
        guard
            let selectedChatRoomId = selectedChatRoomId else { return }
        
        PetSocietyFirebaseManager.shared.fetchThread(with: selectedChatRoomId) { [weak self] result in
            
            switch result {
                
            case .success(let threads):
                
                self?.setThreads(threads)
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
    }
    
    func changedSelectedChatId(with selectedChatRoomId: String) {
        
        self.selectedChatRoomId = selectedChatRoomId
        
    }
    
    func changedSelectedFriendURLString(with selectedFriendURLString: String) {
        
        self.selectedFriendURLString = selectedFriendURLString
        
    }
    
    // MARK: - Convert functions
    
//    private func contertToViewModel<T>(from: T) -> [T] {
//
//    }
    
    private func convertThreadToViewModels(from threads: [Thread]) -> [ThreadViewModel] {
        
        var viewModels = [ThreadViewModel]()
        
        for thread in threads {
            
            let viewModel = ThreadViewModel(model: thread)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    private func setThreads(_ threads: [Thread]) {
        
        threadViewModels.value = convertThreadToViewModels(from: threads)
    }
}

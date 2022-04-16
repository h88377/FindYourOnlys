//
//  ChatRoomThreadViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import Foundation
import UIKit

class ChatRoomMessageViewModel {
    
    let messageViewModels = Box([MessageViewModel]())
    
    private var selectedChatRoomId: String?
    
    var selectedFriendURLString: String?
    
    var message = Message(
        chatRoomId: "", senderId: "", content: "",
        contentImageURLString: "", createdTime: -1
    )
    
    func sendMessage(completion: @escaping (Error?) -> Void) {
        
        PetSocietyFirebaseManager.shared.sendMessage(UserFirebaseManager.shared.currentUser, with: &message) { error in
            
            completion(error)
        }
        
    }
    
    func fetchMessage(completion: @escaping (Error?) -> Void) {
        
        guard
            let selectedChatRoomId = selectedChatRoomId else { return }
        
        PetSocietyFirebaseManager.shared.fetchMessage(with: selectedChatRoomId) { [weak self] result in
            
            switch result {
                
            case .success(let messages):
                
                self?.setMessages(messages)
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
    }
    
    func changedSelectedChatId(with selectedChatRoomId: String) {
        
        self.selectedChatRoomId = selectedChatRoomId
        
        message.chatRoomId = selectedChatRoomId
        
    }
    
    func changedSelectedFriendURLString(with selectedFriendURLString: String) {
        
        self.selectedFriendURLString = selectedFriendURLString
        
    }
    
    func changedContent(with contentText: String) {
        
        message.content = contentText
    }
    
    func changeContent(with contextImage: UIImage) {
        
        //fetchImageURLString with image
    }
    
    // MARK: - Convert functions
    
//    private func contertToViewModel<T>(from: T) -> [T] {
//
//    }
    
    private func convertMessageToViewModels(from messages: [Message]) -> [MessageViewModel] {
        
        var viewModels = [MessageViewModel]()
        
        for message in messages {
            
            let viewModel = MessageViewModel(model: message)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    private func setMessages(_ messages: [Message]) {
        
        messageViewModels.value = convertMessageToViewModels(from: messages)
    }
}

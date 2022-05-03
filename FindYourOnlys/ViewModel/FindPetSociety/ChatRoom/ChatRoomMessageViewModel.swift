//
//  ChatRoomThreadViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import Foundation
import UIKit
import AVFoundation

class ChatRoomMessageViewModel {
    
    let messageViewModels = Box([MessageViewModel]())
    
    private var selectedChatRoom: ChatRoom?
    
    var selectedFriend: User?
    
    var message = Message(
        chatRoomId: "",
        senderId: "",
        content: "",
        contentImageURLString: "",
        createdTime: -1
    )
    
    var editMessageHandler: (() -> Void)?
    
    var beginEditMessageHander: (() -> Void)?
    
    var scrollToBottomHandler: (() -> Void)?
    
    var endEditMessageHandler: (() -> Void)?
    
    var enableIQKeyboardHandler: (() -> Void)?
    
    func editMessage() {
        
        editMessageHandler?()
    }
    
    func beginEditMessage() {
        
        beginEditMessageHander?()
    }
    
    func endEditMessage() {
        
        endEditMessageHandler?()
    }
    
    func scrollToBottom() {
        
        scrollToBottomHandler?()    
    }
    
    func enableIQKeyboard() {
        
        enableIQKeyboardHandler?()
    }
    
    func sendMessage(completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        PetSocietyFirebaseManager.shared.sendMessage(currentUser.id, with: &message) { error in
            
            completion(error)
        }
    }
    
    func fetchMessage(completion: @escaping (Error?) -> Void) {
        
        guard
            let selectedChatRoomId = selectedChatRoom?.id else { return }
        
        PetSocietyFirebaseManager.shared.fetchMessage(with: selectedChatRoomId) { [weak self] result in
            
            switch result {
                
            case .success(let messages):
                
                self?.setMessages(messages)
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
    }
    
    func changedSelectedChatRoom(with selectedChatRoom: ChatRoom) {
        
        self.selectedChatRoom = selectedChatRoom
        
        message.chatRoomId = selectedChatRoom.id
        
    }
    
    func changedSelectedFriend(with selectedFriend: User) {
        
        self.selectedFriend = selectedFriend
        
    }
    
    func changedContent(with contentText: String) {
        
        message.content = contentText
        
        message.contentImageURLString = ""
    }
    
    func changeContent(with contextImage: UIImage, completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
          
        DispatchQueue.global().async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(image: contextImage, with: FirebaseCollectionType.message.rawValue) { result in
                
                switch result {
                    
                case .success(let url):
                    
                    self.message.contentImageURLString = "\(url)"
                    
                    self.message.content = ""
                    
                case .failure(let error):
                    
                    completion(error)
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            PetSocietyFirebaseManager.shared.sendMessage(currentUser.id, with: &self.message) { error in
                
                completion(error)
                
                semaphore.signal()
            }
        }
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

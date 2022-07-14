//
//  ChatRoomThreadViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit.UIImage

class ChatRoomMessageViewModel {
    
    // MARK: - Properties
    
    let messageViewModels = Box([MessageViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    private var selectedChatRoom: ChatRoom?
    
    var selectedFriend: User?
    
    private var message = Message()
    
    var isBlocked: Bool = false
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var checkIsBlockHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func fetchMessage() {
        
        guard
            let selectedChatRoom = selectedChatRoom,
            let currentUser = UserFirebaseManager.shared.currentUser
        else { return }
        
        let isBlocked = selectedChatRoom.userIds.map { currentUser.blockedUsers.contains($0) }.contains(true)
            
        if isBlocked {
            
            messageViewModels.value = []
            
        } else {
            
            PetSocietyFirebaseManager.shared.fetchMessage(with: selectedChatRoom.id) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                    
                case .success(let messages):
                    
                    self.messageViewModels.value = messages.map { MessageViewModel(model: $0) }
                    
                case .failure(let error):
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                }
            }
        }
    }
    
    func sendMessage() {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        PetSocietyFirebaseManager.shared.sendMessage(currentUser.id, with: &message) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
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
    
    func changeContent(with contextImage: UIImage) {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
          
        DispatchQueue.global().async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(
                image: contextImage,
                with: FirebaseCollectionType.message.rawValue
            ) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                    
                case .success(let url):
                    
                    self.message.contentImageURLString = "\(url)"
                    
                    self.message.content = ""
                    
                case .failure(let error):
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            PetSocietyFirebaseManager.shared.sendMessage(currentUser.id, with: &self.message) { [weak self] result in
                
                guard let self = self else { return }
                
                if case .failure(let error) = result {
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                }
                
                semaphore.signal()
            }
        }
    }
    
    func blockUser() {
        
        guard let friend = selectedFriend else { return }
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.blockUser(with: friend.id)
        
        stopLoadingHandler?()
    }
    
    func checkIsBlocked() {
        
        guard
            let friend = selectedFriend,
            let currentUser = UserFirebaseManager.shared.currentUser
        else { return }
        
        isBlocked = currentUser.blockedUsers.contains(friend.id)
        
        checkIsBlockHandler?()
    }
}

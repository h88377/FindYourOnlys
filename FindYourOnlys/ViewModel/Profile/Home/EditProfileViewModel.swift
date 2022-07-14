//
//  EditProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import UIKit.UIImage

class EditProfileViewModel {
    
    // MARK: - Properties
    
    var currentUser: User?
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var selectedImage: UIImage?
    
    var dismissHandler: (() -> Void)?
    
    var backToHomeHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var checkEditedUserHandler: ((Bool) -> Void)?
    
    private var isValidEditedProfile: Bool {
        
        return currentUser?.nickName != "" && currentUser?.nickName != "請輸入你的暱稱"
    }
    
    // MARK: - Methods
    
    func tapConfirm() {
        
        confirm { result in
            
            switch result {
                
            case .success:
                
                self.dismissHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
            self.stopLoadingHandler?()
        }
    }
    func deleteUser() {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.deleteAuthUser { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success:
                
                print("Delete user successfully.")
                
                UserFirebaseManager.shared.currentUser = nil
                
                self.backToHomeHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
            self.stopLoadingHandler?()
        }
    }
    
    func nickNameChange(with nickName: String) {
        
        currentUser?.nickName = nickName
    }
    
    private func confirm(completion: @escaping (Result<Void, Error>) -> Void) {
        
        checkEditedUserHandler?(isValidEditedProfile)
        
        guard
            var currentUser = currentUser,
            isValidEditedProfile
        else { return }

        DispatchQueue.global().async { [weak self] in
            
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.startLoadingHandler?()
            
            switch self.selectedImage != nil {
                
            case true:
                
                PetSocietyFirebaseManager.shared.fetchDownloadImageURL(
                        image: self.selectedImage!,
                        with: FirebaseCollectionType.user.rawValue
                ) { result in
                    
                    switch result {
                        
                    case .success(let url):
                        
                        currentUser.imageURLString = "\(url)"
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                    }

                    semaphore.signal()
                }
                
            case false:
                
                semaphore.signal()
            }
            
            semaphore.wait()
            UserFirebaseManager.shared.saveUser(withUser: currentUser) { result in
                
                switch result {
                    
                case .success:
                    
                    completion(.success(()))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                }
                semaphore.signal()
            }
        }
    }
}

//
//  EditProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import UIKit.UIImage

class EditProfileViewModel {
    
    var currentUser: User?
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var selectedImage: UIImage?
    
    var dismissHandler: (() -> Void)?
    
    var backToHomeHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var openCameraHandler: (() -> Void)?
    
    var openGalleryHandler: (() -> Void)?
    
    var checkEditedUser: ((Bool) -> Void)?
    
    var isValidEditedProfile: Bool {
        
        return currentUser?.nickName != "" && currentUser?.nickName != "請輸入你的暱稱"
    }
    
    func deleteUser() {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.deleteAuthUser { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                print("Delete user successfully.")
                
                UserFirebaseManager.shared.currentUser = nil
                
                self?.stopLoadingHandler?()
                
                self?.backToHomeHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
    
    func openCamera() {
        
        openCameraHandler?()
    }
    
    func openGallery() {
        
        openGalleryHandler?()
    }
    
    private func confirm(completion: @escaping (Result<String, Error>) -> Void) {
        
        checkEditedUser?(isValidEditedProfile)
        
        guard
            var currentUser = currentUser,
            isValidEditedProfile
        
        else { return }

        DispatchQueue.global().async { [weak self] in
            
            guard
                let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.startLoadingHandler?()
            
            switch self.selectedImage != nil {
                
            case true:
                
                PetSocietyFirebaseManager
                    .shared
                    .fetchDownloadImageURL(
                        image: self.selectedImage!,
                        with: FirebaseCollectionType.user.rawValue) { result in
                    
                    switch result {
                        
                    case .success(let url):
                        
                        currentUser.imageURLString = "\(url)"
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                        
                        self.stopLoadingHandler?()
                    }

                    semaphore.signal()
                }
                
            case false:
                
                semaphore.signal()
            }
            
            semaphore.wait()
            UserFirebaseManager.shared.saveUser(withUser: currentUser) { [weak self] result in
                
                switch result {
                    
                case .success(let success):
                    
                    completion(.success(success))
                    
                    self?.stopLoadingHandler?()
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    
                    self?.stopLoadingHandler?()
                }
            }
        }
    }
    
    func tapConfirm() {
        
        confirm { [weak self] result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}

extension EditProfileViewModel {
    
    func nickNameChange(with nickName: String) {
        
        currentUser?.nickName = nickName
    }
}

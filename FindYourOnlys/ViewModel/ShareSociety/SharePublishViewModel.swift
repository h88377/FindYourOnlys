//
//  SharePublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit.UIImage

class SharePublishViewModel {
    
    let shareContentCategory = PublishContentCategory.getCategory(with: .share)
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var article: Article = Article(
        id: "", userId: UserFirebaseManager.shared.currentUser?.id ?? "", likeUserIds: [],
        createdTime: 0,
        city: "", petKind: "",
        content: "", imageURLString: "", comments: []
    )
    
    var updateImage: ((UIImage) -> Void)?
    
    var dismissHandler: (() -> Void)?
    
    var selectedImage: UIImage?
    
    var checkPublishedContent: ((Bool) -> Void)?
    
    var isValidPublishedContent: Bool {
        
        guard
            article.city != "",
            article.postType != -1,
            article.content != "",
            selectedImage != nil
                
        else { return false }
            
        return true
    }
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
}

extension SharePublishViewModel {
    
    func cityChanged(with city: String) {
        
        self.article.city = city
    }
    
    func petKindChanged(with petKind: String) {
        
        self.article.petKind = petKind
    }
    
    func contentChanged(with content: String) {
        
        self.article.content = content
    }
    
    private func publish(completion: @escaping (Result<String, Error>) -> Void) {
        
        checkPublishedContent?(isValidPublishedContent)
        
        guard
            isValidPublishedContent,
            let selectedImage = selectedImage,
            let currentUser = UserFirebaseManager.shared.currentUser
                
        else { return }
        
        DispatchQueue.global().async { [weak self] in
            
            guard
                let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.startLoadingHandler?()
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(
                image: selectedImage,
                with: FirebaseCollectionType.article.rawValue) { result in
                
                switch result {
                    
                case .success(let url):
                    
                    self.article.imageURLString = "\(url)"
                    
//                    completion(nil)
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    
//                    completion(error)
//
//                    self.stopLoadingHandler?()
                }

                semaphore.signal()
            }
            

            semaphore.wait()
            PetSocietyFirebaseManager.shared.publishArticle(
                currentUser.id, with: &self.article) { result in
                    
                    switch result {
                        
                    case .success(let success):
                        
                        completion(.success(success))
                        
                        
//                        completion(nil)
//
//                        self.stopLoadingHandler?()
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                        
                        
//                        completion(error)
//
//                        self.stopLoadingHandler?()
                    }
                    
                    semaphore.signal()
                }
        }
    }
    
    func tapPublish() {
        
        publish { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                self?.stopLoadingHandler?()
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}

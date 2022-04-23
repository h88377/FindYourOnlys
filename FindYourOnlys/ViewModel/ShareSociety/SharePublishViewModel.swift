//
//  SharePublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit.UIImage

class SharePublishViewModel {
    
    let shareContentCategory = ShareContentCategory.allCases
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var article: Article = Article(
        id: "", userId: UserFirebaseManager.shared.currentUser, likeUserIds: [],
        createdTime: 0,
        city: "", petKind: "",
        content: "", imageURLString: "", comments: []
    )
    
    var updateImage: ((UIImage) -> Void)?
    
    var finishPublishHandler: (() -> Void)?
    
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
    
    private func publish(completion: @escaping (Error?) -> Void) {
        
        checkPublishedContent?(isValidPublishedContent)
        
        guard
            isValidPublishedContent,
              let selectedImage = selectedImage
                
        else { return }
        
        print("Published content is valid")
        
        DispatchQueue.global().async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(
                image: selectedImage,
                with: FirebaseCollectionType.article.rawValue) { result in
                
                switch result {
                    
                case .success(let url):
                    
                    self.article.imageURLString = "\(url)"
                    
                    completion(nil)
                    
                case .failure(let error):
                    
                    completion(error)
                }

                semaphore.signal()
            }
            

            semaphore.wait()
            PetSocietyFirebaseManager.shared.publishSharedArticle(
                UserFirebaseManager.shared.currentUser, with: &self.article) { error in

                guard
                    error == nil
                
                else {
                    
                    completion(error)
                    
                    return
                    }
                
                completion(nil)
                
                semaphore.signal()
            }
            
        }
    }
    
    func tapPublish() {
        
        publish { [weak self] error in
            
            guard
                error == nil
            
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
                
                }
            
            self?.finishPublishHandler?()
        }
    }
}

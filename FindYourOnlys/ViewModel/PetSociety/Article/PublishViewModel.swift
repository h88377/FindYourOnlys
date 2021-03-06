//
//  PublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit.UIImage

class PublishViewModel {
    
    // MARK: - Properties
    
    var articleType: ArticleType?
    
    var article = Article()
    
    var publishContentCategory: [PublishContentCategory] {
        
        switch articleType {
            
        case .find:
            
            return PublishContentCategory.getCategory(with: .find)
            
        case .share:
            
            return PublishContentCategory.getCategory(with: .share)
            
        default:
            
            return []
        }
    }
    
    var error: Box<Error?> = Box(nil)
    
    var selectedImage: UIImage? {
        
        didSet {
            
            isValidDetectResult = false
        }
    }
    
    private var isValidPublishedContent: Bool {
        
        switch articleType {
            
        case .find:
            
            guard
                article.city != "",
                article.color != "",
                article.petKind != "",
                article.postType != nil,
                article.content != "",
                selectedImage != nil
            else { return false }
                
            return true
            
        case .share:
            
            guard
                article.city != "",
                article.content != "",
                selectedImage != nil
            else { return false }
                
            return true
            
        default:
            
            return false
        }
    }
    
    private var isValidDetectResult = false
    
    var checkPublishedContentHandler: ((Bool, Bool) -> Void)?
    
    var updateImageHandler: ((UIImage) -> Void)?
    
    var dismissHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var startScanningHandler: (() -> Void)?
    
    var stopScanningHandler: (() -> Void)?
    
    var imageDetectHandler: (() -> Void)?
    
    var successHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func tapPublish() {
        
        publish { result in
            
            switch result {
                
            case .success:
                
                self.dismissHandler?()
                
            case .failure(let error):
                
                self.error.value = error
            }
            
            self.stopLoadingHandler?()
        }
    }
    
    func detectImage() {
        
        guard let selectedImage = selectedImage else {
            
            error.value = GoogleMLError.noImage
            
            return
        }
        
        startScanningHandler?()
        
        GoogleMLWrapper.shared.detectLabels(with: selectedImage) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let labels):
                
                self.isValidDetectResult = GoogleMLWrapper.shared.getDetectResult(with: labels)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.8) {
                    
                    self.stopScanningHandler?()
                    
                    if self.isValidDetectResult {
                        
                        self.successHandler?()
                        
                    } else {
                        
                        self.error.value = GoogleMLError.detectFailure
                    }
                }
                
            case .failure(let error):
                
                self.error.value = error
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.8) {
                    
                    self.stopScanningHandler?()
                }
            }
        }
    }
    
    private func publish(completion: @escaping (Result<Void, Error>) -> Void) {
        
        checkPublishedContentHandler?(isValidPublishedContent, isValidDetectResult)
        
        guard
            isValidPublishedContent,
            isValidDetectResult,
            let selectedImage = selectedImage
        else { return }
        
        DispatchQueue.global().async { [weak self] in
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser,
                let self = self
            else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.startLoadingHandler?()
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(
                image: selectedImage,
                with: FirebaseCollectionType.article.rawValue
            ) { result in
                
                switch result {
                    
                case .success(let url):
                    
                    self.article.imageURLString = "\(url)"
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                }

                semaphore.signal()
            }
            
            semaphore.wait()
            PetSocietyFirebaseManager.shared.publishArticle(
                currentUser.id,
                with: &self.article
            ) { result in

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
    
    func cityChanged(with city: String) {
        
        self.article.city = city
    }
    
    func colorChanged(with color: String) {
        
        self.article.color = color
    }
    
    func petKindChanged(with petKind: String) {
        
        self.article.petKind = petKind
    }
    
    func postTypeChanged(with type: String) {
        
        if type == PostType.missing.rawValue {
            
            self.article.postType = 0
            
        } else {
            
            self.article.postType = 1
        }
    }
    
    func contentChanged(with content: String) {
        
        self.article.content = content
    }
}

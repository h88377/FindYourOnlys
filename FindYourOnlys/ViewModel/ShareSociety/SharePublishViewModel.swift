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
    
    var article: Article = Article()
    
    var updateImage: ((UIImage) -> Void)?
    
    var dismissHandler: (() -> Void)?
    
    var selectedImage: UIImage? {
        
        didSet {
            
            isValidDetectResult = false
        }
    }
    
    var checkPublishedContent: ((Bool, Bool) -> Void)?
    
    var isValidPublishedContent: Bool {
        
        guard
            article.city != "",
            article.postType != -1,
            article.content != "",
            selectedImage != nil
                
        else { return false }
            
        return true
    }
    
    var isValidDetectResult: Bool = false
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var startScanningHandler: (() -> Void)?
    
    var stopScanningHandler: (() -> Void)?
    
    var imageDetectHandler: (() -> Void)?
    
    var successHandler: (() -> Void)?
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
    
    private func publish(completion: @escaping (Result<Void, Error>) -> Void) {
        
        checkPublishedContent?(isValidPublishedContent, isValidDetectResult)
        
        guard
            isValidPublishedContent,
            isValidDetectResult,
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
                        
                    case .success:
                        
                        completion(.success(()))
                        
                        
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
                
            case .success:
                
                self?.stopLoadingHandler?()
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
    
    func detectImage() {
        
        guard
            let selectedImage = selectedImage
        
        else {
            
            errorViewModel.value = ErrorViewModel(model: GoogleMLError.noImage)
            
                return
            }

        startScanningHandler?()
        
        GoogleMLWrapper.shared.detectLabels(with: selectedImage) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let labels):
                
                let imageDetectDatabase = ImageDetectDatabase.allCases.map { $0.rawValue }
                
                let isValidResult = labels.map { label in
                    
                    imageDetectDatabase.contains(label.text)
                    
                }.contains(true)
                
                self.isValidDetectResult = isValidResult
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    
                    self.stopScanningHandler?()
                    
                    if isValidResult {
                        
                        self.successHandler?()
                        
                    } else {
                        
                        self.errorViewModel.value = ErrorViewModel(model: GoogleMLError.detectFailure)
                    }
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.8) {
                    
                    self.stopScanningHandler?()
                }
            }
        }
    }
}

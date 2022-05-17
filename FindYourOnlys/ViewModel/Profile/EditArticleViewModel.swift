//
//  EditArticleViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import UIKit.UIImage
import UIKit


class EditArticleViewModel {
    
    var editContentCategory: [PublishContentCategory] {
        
        switch isFindArticle {
            
        case true:
            
            return PublishContentCategory.getCategory(with: .find)
            
        case false:
            
            return PublishContentCategory.getCategory(with: .share)
        }
    }
    
    var article = Article(
        id: "",
        userId: UserFirebaseManager.shared.currentUser?.id ?? "",
        likeUserIds: [],
        createdTime: 0,
        city: "",
        content: "",
        imageURLString: "",
        comments: []
    )
    
//    init(model: Article) {
//
//        self.article = model
//    }
    
    var isFindArticle: Bool {
        
        return article.postType != nil
    }
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var updateImage: ((UIImage) -> Void)?
    
    var selectedImage: UIImage? {
        
        didSet {
            
            isValidDetectResult = false
        }
    }
    
    var checkEditedContent: ((Bool, Bool) -> Void)?
    
    var isValidDetectResult: Bool = true
    
    var dismissHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var startScanningHandler: (() -> Void)?
    
    var stopScanningHandler: (() -> Void)?
    
    var imageDetectHandler: (() -> Void)?
    
    var successHandler: (() -> Void)?
    
    var isValidEditedContent: Bool {
        
        return article.content != "" && article.content != "請輸入你的內文"
    }
    
    private func edit(completion: @escaping (Result<String, Error>) -> Void) {
        
        checkEditedContent?(isValidEditedContent, isValidDetectResult)
        
        guard
            isValidEditedContent,
            isValidDetectResult
                
        else { return }
        
        DispatchQueue.global().async { [weak self] in
            
            guard
                let self = self
                    
            else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.startLoadingHandler?()
            
            switch self.selectedImage != nil {
                
            case true:
                
                PetSocietyFirebaseManager
                    .shared
                    .fetchDownloadImageURL(
                        image: self.selectedImage!, with: FirebaseCollectionType.article.rawValue) { result in
                    
                    switch result {
                        
                    case .success(let url):
                        
                        self.article.imageURLString = "\(url)"
                        
//                        completion(nil)
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                        
//                        completion(error)
                        
//                        self.stopLoadingHandler?()
                    }

                    semaphore.signal()
                }
                
            case false:
                
                semaphore.signal()
            }
     
            semaphore.wait()
            PetSocietyFirebaseManager.shared.editArticle(with: &self.article) { result in

                switch result {
                    
                case .success(let success):
                    
//                    self?.stopLoadingHandler?()
                    
                    completion(.success(success))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    
//                    self?.errorViewModel.value = ErrorViewModel(model: error)
                    
//                    self?.stopLoadingHandler?()
                }
            }
        }
    }
    
    func tapEdit() {
        
        edit { [weak self] result in
            
            switch result {
                
            case .success(_):
                
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
//            let selectedImage = selectedImage
            article.imageURLString != ""
        
        else {
            
            errorViewModel.value = ErrorViewModel(model: GoogleMLError.noImage)
            
                return
            }

        startScanningHandler?()
        
        let image: UIImage
        
        switch selectedImage == nil {
            
        case true:
            
            let imageView = UIImageView()
            
            imageView.loadImage(article.imageURLString)
            
            image = imageView.image!
            
        case false:
            
            image = selectedImage!
        }
        
        GoogleMLWrapper.shared.detectLabels(with: image) { [weak self] result in
            
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

extension EditArticleViewModel {
    
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

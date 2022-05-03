//
//  EditArticleViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import UIKit.UIImage

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
    
    var selectedImage: UIImage?
    
    var checkEditedContent: ((Bool) -> Void)?
    
    var dismissHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var isValidEditedContent: Bool {
        
        return article.content != "" && article.content != "請輸入你的內文"
    }
    
    private func edit(completion: @escaping (Error?)-> Void) {
        
        checkEditedContent?(isValidEditedContent)
        
        guard
            isValidEditedContent
                
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
                        
                        completion(nil)
                        
                    case .failure(let error):
                        
                        completion(error)
                        
                        self.stopLoadingHandler?()
                    }

                    semaphore.signal()
                }
                
            case false:
                
                semaphore.signal()
            }
     
            semaphore.wait()
            PetSocietyFirebaseManager.shared.editArticle(with: &self.article) { error in

                guard
                    error == nil
                
                else {
                    
                    completion(error)
                    
                    self.stopLoadingHandler?()
                    
                    return
                    }
                
                completion(nil)
                
                self.stopLoadingHandler?()
            }
            
        }
    }
    
    func tapEdit() {
        
        edit { [weak self] error in
            
            guard
                error == nil
            
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
                
                }
            
            self?.dismissHandler?()
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

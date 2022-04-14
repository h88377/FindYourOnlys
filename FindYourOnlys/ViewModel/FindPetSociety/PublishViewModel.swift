//
//  PublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import UIKit

class PublishViewModel {
    
    let publishContentCategory = PublishContentCategory.allCases
    
    var article: Article = Article(
        id: "", userId: UserManager.shared.currentUser, likeUserIds: [],
        createdTime: 0, postType: -1,
        city: "", petKind: "", color: "",
        content: "", imageURLString: "", comments: []
    )
    
    var updateImage: ((UIImage) -> Void)?
    
    var selectedImage: UIImage?
    
    var checkPublishedContent: ((Bool) -> Void)?
    
    var isValidPublishedContent: Bool {
        
        guard
            article.city != "",
            article.color != "",
            article.petKind != "",
            article.postType != -1,
            article.content != "",
            selectedImage != nil
                
        else { return false }
            
        return true
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
    
    private func publish(completion: @escaping (Error?)-> Void) {
        
        checkPublishedContent?(isValidPublishedContent)
        
        guard
            isValidPublishedContent,
              let selectedImage = selectedImage
                
        else { return }
        
        print("Published content is valid")
        
        DispatchQueue.global().async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(image: selectedImage, with: self.article.id) { result in
                
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
            PetSocietyFirebaseManager.shared.publishArticle(UserManager.shared.currentUser, with: &self.article) { error in

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
    
    func tapPublish(completion: @escaping (Error?)-> Void) {
        
        publish { error in
            
            guard
                error == nil
            
            else {
                
                completion(error)
                
                return
                }
            
            completion(nil)
        }
    }
    
}

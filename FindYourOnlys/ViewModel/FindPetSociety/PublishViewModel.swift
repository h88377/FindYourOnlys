//
//  PublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

class PublishViewModel {
    
    let publishContentCategory = PublishContentCategory.allCases
    
    var article: Article = Article(
        id: "", userId: UserManager.shared.currentUser, likeUserIds: [],
        createdTime: 123, postType: 0,
        city: "", petKind: "", color: "",
        content: "", imageURLString: "", comments: []
    )
    
    func cityChanged(with city: String) {
        
        self.article.city = city
    }
    
    func colorChanged(with color: String) {
        
        self.article.color = color
    }
    
    func petKindChangede(with petKind: String) {
        
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
    
    func publish(completion: @escaping (Error?)-> Void) {
        
        PetSocietyFirebaseManager.shared.publishArticle(UserManager.shared.currentUser, with: &article) { error in
            
            completion(error)
        }
        
    }
    
    func tapPublish(completion: @escaping (Error?)-> Void) {
        
        publish { error in
            completion(error)
        }
    }
    
    
}

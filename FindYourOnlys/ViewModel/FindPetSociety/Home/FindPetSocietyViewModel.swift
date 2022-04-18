//
//  FindPetSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

class FindPetSocietyViewModel {
    
    let articleViewModels = Box([ArticleViewModel]())
    
    let authorViewModels = Box([UserViewModel]())
    
    func fetchArticles(completion: @escaping (Error?) -> Void) {
        
        PetSocietyFirebaseManager.shared.fetchArticle { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let articles):
                
                PetSocietyFirebaseManager.shared.setArticles(with: self.articleViewModels, articles: articles)
                
                self.fetchAuthors(with: articles) { error in
                    
                    completion(error)
                }
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
    }
    
    func fetchAuthors(with articles: [Article], completion: @escaping (Error?) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                var authors = [User]()
                
                for article in articles {
                    
                    for user in users {
                        
                        if article.userId == user.id {
                            
                            authors.append(user)
                        }
                    }
                }
                
                UserFirebaseManager.shared.setUsers(with: self.authorViewModels, users: authors)
                
            case .failure(let error):
                
                completion(error)
                
            }
        }
    }
    
}

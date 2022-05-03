//
//  ShareSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import Foundation

class ShareSocietyViewModel: BaseSocietyViewModel {
    
    let articleViewModels = Box([ArticleViewModel]())
    
    let authorViewModels = Box([UserViewModel]())
    
    func fetchSharedArticles() {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .share) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let articles):
                
                PetSocietyFirebaseManager.shared.setArticles(with: self.articleViewModels, articles: articles)
                
                self.fetchAuthors(with: articles) { error in
                    
                    self.errorViewModel.value = ErrorViewModel(model: error!)
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
        
    }
    
    private func fetchAuthors(with articles: [Article], completion: @escaping (Error?) -> Void) {
        
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
                
                self.stopLoadingHandler?()
                
            case .failure(let error):
                
                completion(error)
                
                self.stopLoadingHandler?()
            }
        }
    }
}

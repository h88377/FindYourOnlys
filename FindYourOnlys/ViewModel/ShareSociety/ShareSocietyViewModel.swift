//
//  ShareSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import Foundation

class ShareSocietyViewModel {
    
    let articleViewModels = Box([ArticleViewModel]())
    
    let authorViewModels = Box([UserViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var shareHanlder: ((ArticleViewModel) -> Void)?
    
    func fetchSharedArticles() {
        
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
            }
        }
        
    }
    
    func likeArticle(with articleViewModel: ArticleViewModel) {
        
        PetSocietyFirebaseManager.shared.likeArticle(with: &articleViewModel.article) { error in
            
            guard
                error == nil
                    
            else {
                
                self.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
        }
    }
    
    func unlikeArticle(with articleViewModel: ArticleViewModel) {
        
        PetSocietyFirebaseManager.shared.unlikeArticle(with: &articleViewModel.article) { error in
            
            guard
                error == nil
                    
            else {
                
                self.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
        }
    }
    
    func shareArticle(with articleViewModel: ArticleViewModel) {
        
        shareHanlder?(articleViewModel)
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
                
            case .failure(let error):
                
                completion(error)
                
            }
        }
    }
}

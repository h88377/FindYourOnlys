//
//  FindPetSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

class PetSocietyViewModel: BaseSocietyViewModel {
    
    // MARK: - Properties
    
    let findArticles = Box([Article]())
    
    let findAuthors = Box([User]())
    
    let sharedArticles = Box([Article]())
    
    let sharedAuthors = Box([User]())
    
    var findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
    
    var profileSelectedArticle: Box<Article?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func fetchFindArticles(with condition: FindPetSocietyFilterCondition? = nil) {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .find, with: condition) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(var articles):
                
                self.filterOutBlockedComments(with: &articles)
                
//                PetSocietyFirebaseManager.shared.setArticles(with: self.findArticles, articles: articles)
                
                self.findArticles.value = articles
                
                self.fetchAuthors(with: articles, type: .find) { error in
                    
                    self.error.value = error
                }
                
            case .failure(let error):
                
                self.error.value = error
                
                self.stopLoadingHandler?()
            }
        }
        
    }
    
    func fetchSharedArticles() {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .share) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(var articles):
                
                self.filterOutBlockedComments(with: &articles)
                
//                PetSocietyFirebaseManager.shared.setArticles(with: self.sharedArticles, articles: articles)
                
                self.sharedArticles.value = articles
                
                self.fetchAuthors(with: articles, type: .share) { error in
                    
                    self.error.value = error!
                }
                
            case .failure(let error):
                
                self.error.value = error
                
                self.stopLoadingHandler?()
            }
        }
        
    }
    
    func fetchSelectedArticle() {
        
        guard let selectedArticle = profileSelectedArticle.value else { return }
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(withArticleId: selectedArticle.id) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let article):
                
                self.profileSelectedArticle.value = article
                
            case .failure(let error):
                
                self.error.value = error
            }
            self.stopLoadingHandler?()
        }
    }
    
    private func fetchAuthors(with articles: [Article], type: ArticleType, completion: @escaping (Error?) -> Void) {
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                var authors = [User]()
                
                for article in articles {
                    
                    for user in users where user.id == article.userId {
                            
                        authors.append(user)
                    }
                }
                
                switch type {
                    
                case .find:
                    
//                    UserFirebaseManager.shared.setUsers(with: self.findAuthors, users: authors)
                    self.findAuthors.value = authors
                    
                case .share:
                    
//                    UserFirebaseManager.shared.setUsers(with: self.sharedAuthors, users: authors)
                    self.sharedAuthors.value = authors
                }
                  
            case .failure(let error):
                
                completion(error)
            }
            
            self.stopLoadingHandler?()
        }
    }
    
    private func filterOutBlockedComments(with articles: inout [Article]) {
        
        if let currentUser = UserFirebaseManager.shared.currentUser {
            
            for index in 0..<articles.count {
                
                let filteredComments = articles[index].comments.filter {
                    
                    !currentUser.blockedUsers.contains($0.userId)
                }
                
                articles[index].comments = filteredComments
            }
        }
    }
    
    func deleteArticle(with article: Article) {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.deleteArticle(withArticleId: article.id) { result in
            
            switch result {
                
            case .success:
                
                self.dismissHandler?()
                
            case .failure(let error):
                
                self.error.value = error
            }
            self.stopLoadingHandler?()
        }
    }
    
    func blockUser(with article: Article) {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.blockUser(with: article.userId)
        
        stopLoadingHandler?()
    }
}

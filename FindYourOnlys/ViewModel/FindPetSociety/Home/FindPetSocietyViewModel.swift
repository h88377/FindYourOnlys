//
//  FindPetSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

class FindPetSocietyViewModel: BaseSocietyViewModel {
    
    // MARK: - Properties
    
    let articleViewModels = Box([ArticleViewModel]())
    
    let authorViewModels = Box([UserViewModel]())
    
    var findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
    
    // MARK: - Methods
    
    func fetchArticles(with condition: FindPetSocietyFilterCondition? = nil) {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .find, with: condition) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(var articles):
                
                self.filterOutBlockedComments(with: &articles)
                
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
                    
                    for user in users where user.id == article.userId {
                            
                        authors.append(user)
                    }
                }
                
                UserFirebaseManager.shared.setUsers(with: self.authorViewModels, users: authors)
                
            case .failure(let error):
                
                completion(error)
            }
            
            self.stopLoadingHandler?()
        }
    }
    
    private func filterOutBlockedComments(with articles: inout [Article]) {
        
        if
            let currentUser = UserFirebaseManager.shared.currentUser {
            
            for index in 0..<articles.count {
                
                let filteredComments = articles[index].comments.filter {
                    
                    !currentUser.blockedUsers.contains($0.userId)
                }
                
                articles[index].comments = filteredComments
            }
        }
    }
    
    func deleteArticle(with viewModel: ArticleViewModel) {
        
        let article = viewModel.article
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.deleteArticle(withArticleId: article.id) { [weak self] result in
            
            guard
                let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
            
            self.stopLoadingHandler?()
        }
    }
    
    func blockUser(with viewModel: ArticleViewModel) {
        
        let article = viewModel.article
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.blockUser(with: article.userId)
        
        stopLoadingHandler?()
    }
}

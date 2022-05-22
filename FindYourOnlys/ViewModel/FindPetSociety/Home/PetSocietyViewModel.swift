//
//  FindPetSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

//enum SocietyModel {
//
//    case find
//
//    case shared
//
//    func condition() -> FindPetSocietyFilterCondition? {
//
//        switch self {
//        case .find:
//            <#code#>
//        case .shared:
//            <#code#>
//        }
//    }
//
//    func fetchArticle(condition: FindPetSocietyFilterCondition?) {
//
//        switch self {
//
//        case .find:
//
//
//
//        case .shared:
//            <#code#>
//        }
//    }
//}

class PetSocietyViewModel: BaseSocietyViewModel {
    
    // MARK: - Properties
    
    let findArticleViewModels = Box([ArticleViewModel]())
    
    let findAuthorViewModels = Box([UserViewModel]())
    
    let sharedArticleViewModels = Box([ArticleViewModel]())
    
    let sharedAuthorViewModels = Box([UserViewModel]())
    
    var findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
    
    // MARK: - Methods
    
    func fetchFindArticles(with condition: FindPetSocietyFilterCondition? = nil) {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .find, with: condition) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(var articles):
                
                self.filterOutBlockedComments(with: &articles)
                
                PetSocietyFirebaseManager.shared.setArticles(with: self.findArticleViewModels, articles: articles)
                
                self.fetchAuthors(with: articles, type: .find) { error in
                    
                    self.errorViewModel.value = ErrorViewModel(model: error!)
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
        
    }
    
    func fetchSharedArticles() {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .share) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(var articles):
                
                self.filterOutBlockedComments(with: &articles)
                
                PetSocietyFirebaseManager.shared.setArticles(with: self.sharedArticleViewModels, articles: articles)
                
                self.fetchAuthors(with: articles, type: .share) { error in
                    
                    self.errorViewModel.value = ErrorViewModel(model: error!)
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
        
    }
    
    private func fetchAuthors(with articles: [Article], type: ArticleType, completion: @escaping (Error?) -> Void) {
        
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
                
                switch type {
                    
                case .find:
                    
                    UserFirebaseManager.shared.setUsers(with: self.findAuthorViewModels, users: authors)
                    
                case .share:
                    
                    UserFirebaseManager.shared.setUsers(with: self.sharedAuthorViewModels, users: authors)
                }
                  
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

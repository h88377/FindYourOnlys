//
//  FindPetSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

class FindPetSocietyViewModel: BaseSocietyViewModel {
    
    let articleViewModels = Box([ArticleViewModel]())
    
    let authorViewModels = Box([UserViewModel]())
    
    var findPetSocietyFilterCondition = FindPetSocietyFilterCondition(
        postType: -1,
        city: "",
        petKind: "",
        color: ""
    )
    
    func fetchArticles(with condition: FindPetSocietyFilterCondition? = nil) {
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(articleType: .find, with: condition) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(var articles):
                
                if
                    let currentUser = UserFirebaseManager.shared.currentUser {
                    
                    for index in 0..<articles.count {
                        
                        let filteredComments = articles[index].comments.filter { !currentUser.blockedUsers.contains($0.userId) }
                        
                        articles[index].comments = filteredComments
                    }
                }
                
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
    
    func deleteArticle(with viewModel: ArticleViewModel) {
        
        let article = viewModel.article
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.deleteArticle(withArticleId: article.id) { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                self?.stopLoadingHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
    
    func blockUser(with viewModel: ArticleViewModel) {
        
        let article = viewModel.article
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.blockUser(with: article.userId)
        
        stopLoadingHandler?()
    }
}

extension FindPetSocietyViewModel {
    
    func cityChanged(with city: String) {
        
        findPetSocietyFilterCondition.city = city
    }
    
    func petKindChanged(with petKind: String) {
        
        findPetSocietyFilterCondition.petKind = petKind
    }
    
    func postTypeChanged(with postType: String) {
        
        if postType == PostType.missing.rawValue {
            
            findPetSocietyFilterCondition.postType = 0
            
        } else {
            
            findPetSocietyFilterCondition.postType = 1
        }
    }
    
    func colorChanged(with color: String) {
        
        findPetSocietyFilterCondition.color = color
    }
}

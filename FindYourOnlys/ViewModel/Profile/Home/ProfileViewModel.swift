//
//  ProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class ProfileViewModel {
    
    // MARK: - Properties
    
    var user: Box<User?> = Box(nil)
    
    var error: Box<Error?> = Box(nil)
    
    var profileArticles = Box([ProfileArticle]())
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var backToHomeHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func fetchCurrentUser() {
        
        guard let currentUserId = UserFirebaseManager.shared.initialUser?.uid else { return }
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                for user in users where user.id == currentUserId {
                    
                    self.user.value = user
                    
                    break
                }
                
            case .failure(let error):
                
                self.error.value = error
            }
            
            self.stopLoadingHandler?()
        }
    }
    
    func fetchProfileArticle() {
        
        PetSocietyFirebaseManager.shared.fetchArticle { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let articles):
                
                self.profileArticles.value = self.getProfileArticles(with: articles)
                
            case .failure(let error):
                
                self.error.value = error
            }
            self.stopLoadingHandler?()
        }
    }
    
    func signOut() {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.signOut { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success:
                
                self.backToHomeHandler?()
                
                UserFirebaseManager.shared.currentUser = nil
                
            case .failure(let error):
                
                self.error.value = error
            }
            self.stopLoadingHandler?()
        }
    }
    
    private func getProfileArticles(with articles: [Article]) -> [ProfileArticle] {
        
        var findingProfileArticles = ProfileArticle(articleType: .find, articles: [Article]())
        
        var shareProfileArticles = ProfileArticle(articleType: .share, articles: [Article]())
        
        for article in articles {
            
            switch article.postType != nil {
                
            case true:
                
                findingProfileArticles.articles.append(article)
                
            case false:
                
                shareProfileArticles.articles.append(article)
            }
        }
        
        return [findingProfileArticles, shareProfileArticles]
    }
}

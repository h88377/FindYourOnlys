//
//  ProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class ProfileViewModel {
    
    var userViewModel: Box<UserViewModel?> = Box(nil)
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var profileArticleViewModels = Box([ProfileArticleViewModel]())
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    func fetchCurrentUser() {
        
        guard
            let currentUserId = UserFirebaseManager.shared.initialUser?.uid
                
        else { return }
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                for user in users where user.id == currentUserId {
                    
                    self?.userViewModel.value = UserViewModel(model: user)
                    
                    break
                }
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
    
    func fetchProfileArticle() {
        
        PetSocietyFirebaseManager.shared.fetchArticle() { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let articles):
                
                var missingProfileArticles = ProfileArticle(articleType: .find, articles: [Article]())
                
                var shareProfileArticles = ProfileArticle(articleType: .share, articles: [Article]())
                
                for article in articles {
                    
                    switch article.postType != nil {
                        
                    case true:
                        
                        missingProfileArticles.articles.append(article)
                        
                    case false:
                        
                        shareProfileArticles.articles.append(article)
                    }
                }
                
                PetSocietyFirebaseManager.shared.setProfileArticles(
                    with: self.profileArticleViewModels,
                    profileArticles: [missingProfileArticles, shareProfileArticles]
                )
                
                self.stopLoadingHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
    }
    
    func signOut() {
        
        UserFirebaseManager.shared.signOut { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
            
            print("Sign out successfully.")
            
            UserFirebaseManager.shared.currentUser = nil
        }
    }
    
//    func deleteUser() {
//
//        UserFirebaseManager.shared.deleteAuthUser { [weak self] error in
//
//            guard
//                error == nil
//
//            else {
//
//                self?.errorViewModel.value = ErrorViewModel(model: error!)
//
//                return
//            }
//
//            print("Delete user successfully.")
//
//            UserFirebaseManager.shared.currentUser = nil
//        }
//    }
}

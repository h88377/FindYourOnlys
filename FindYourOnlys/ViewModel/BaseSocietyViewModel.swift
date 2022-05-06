//
//  BaseSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import Foundation

class BaseSocietyViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var shareHanlder: ((ArticleViewModel) -> Void)?
    
    var editHandler: ((ArticleViewModel, UserViewModel) -> Void)?
    
    var tapAddArticleHandler: (() -> Void)?
    
    var signInHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    func likeArticle(with articleViewModel: ArticleViewModel) {
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
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
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
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
    
    func editArticle(with articleViewModel: ArticleViewModel, authorViewModel: UserViewModel) {
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
        editHandler?(articleViewModel, authorViewModel)
    }
    
    func tapAddArticle() {
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
        tapAddArticleHandler?()
    }
}

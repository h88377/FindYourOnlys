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
    
    var editHandler: ((ArticleViewModel) -> Void)?
    
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
        
        PetSocietyFirebaseManager.shared.likeArticle(with: &articleViewModel.article) { result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
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
        
        PetSocietyFirebaseManager.shared.unlikeArticle(with: &articleViewModel.article) { [weak self] result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func shareArticle(with articleViewModel: ArticleViewModel) {
        
        shareHanlder?(articleViewModel)
    }
    
    func editArticle(with articleViewModel: ArticleViewModel) {
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
        editHandler?(articleViewModel)
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

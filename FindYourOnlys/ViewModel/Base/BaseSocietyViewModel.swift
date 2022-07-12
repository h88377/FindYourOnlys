//
//  BaseSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import Foundation

class BaseSocietyViewModel {
    
    // MARK: - Properties
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var editHandler: ((ArticleViewModel) -> Void)?
    
    var tapAddArticleHandler: (() -> Void)?
    
    var signInHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func likeArticle(with articleViewModel: ArticleViewModel) {
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
        PetSocietyFirebaseManager.shared.likeArticle(with: &articleViewModel.article) { [weak self] result in
            
            guard
                let self = self else { return }
            
            if case .failure(let error) = result {
                
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
            
            guard
                let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
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

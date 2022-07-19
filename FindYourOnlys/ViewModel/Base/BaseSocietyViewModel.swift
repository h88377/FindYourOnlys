//
//  BaseSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import Foundation

class BaseSocietyViewModel {
    
    // MARK: - Properties
    
    var error: Box<Error?> = Box(nil)
    
    var editHandler: ((Article) -> Void)?
    
    var tapAddArticleHandler: (() -> Void)?
    
    var signInHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func likeArticle(with article: Article) {
        
        var variableArticle = article
        
        guard UserFirebaseManager.shared.currentUser != nil else {
            
            signInHandler?()
            
            return
        }
        
        PetSocietyFirebaseManager.shared.likeArticle(with: &variableArticle) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.error.value = error
            }
        }
    }
    
    func unlikeArticle(with article: Article) {
        
        var variableArticle = article
        
        guard UserFirebaseManager.shared.currentUser != nil else {
            
            signInHandler?()
            
            return
        }
        
        PetSocietyFirebaseManager.shared.unlikeArticle(with: &variableArticle) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.error.value = error
            }
        }
    }
    
    func editArticle(with article: Article) {
        
        guard UserFirebaseManager.shared.currentUser != nil else {
            
            signInHandler?()
            
            return
        }
        
        editHandler?(article)
    }
    
    func tapAddArticle() {
        
        guard UserFirebaseManager.shared.currentUser != nil else {
            
            signInHandler?()
            
            return
        }
        
        tapAddArticleHandler?()
    }
}

//
//  ProfileSelectedArticleViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import Foundation

class ProfileSelectedArticleViewModel: BaseSocietyViewModel {
    
    var articleViewModel: Box<ArticleViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    func fetchArticle() {
        
        guard
            let article = articleViewModel.value?.article else { return }
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.fetchArticle(withArticleId: article.id) { [weak self] result in
            
            switch result {
                
            case .success(let article):
                
                self?.articleViewModel.value = ArticleViewModel(model: article)
                
                self?.stopLoadingHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
    
    func deleteArticle() {
        
        guard
            let article = articleViewModel.value?.article
                
        else { return }
        
        startLoadingHandler?()
        
        PetSocietyFirebaseManager.shared.deleteArticle(withArticleId: article.id) { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                self?.stopLoadingHandler?()
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
    
}

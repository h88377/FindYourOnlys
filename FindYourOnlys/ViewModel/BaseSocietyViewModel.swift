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
    
    func likeArticle(with articleViewModel: ArticleViewModel) {
        
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
        
        editHandler?(articleViewModel, authorViewModel)
    }
}

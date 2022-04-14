//
//  FindPetSocietyViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import UIKit.UIImage

class FindPetSocietyViewModel {
    
    let articleViewModels = Box([ArticleViewModel]())
    
    func fetchArticles(completion: @escaping (Error?) -> Void) {
        
        PetSocietyFirebaseManager.shared.fetchArticle { [weak self] result in
            
            switch result {
                
            case .success(let articles):
                
                self?.setArticles(articles)
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
    }
    
    private func convertArticlesToViewModels(from articles: [Article]) -> [ArticleViewModel] {
        
        var viewModels = [ArticleViewModel]()
        
        for article in articles {
            
            let viewModel = ArticleViewModel(model: article)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    private func setArticles(_ articles: [Article]) {
        
        articleViewModels.value = convertArticlesToViewModels(from: articles)
    }
}

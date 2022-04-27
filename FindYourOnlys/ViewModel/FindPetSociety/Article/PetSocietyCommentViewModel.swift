//
//  PetSocietyCommentViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import Foundation

class PetSocietyCommentViewModel {
    
    var article: Article?
    
    var commentViewModels = Box([CommentViewModel]())
    
    var senderViewModels = Box([UserViewModel]())
    
    var comment = Comment(
        articleId: "",
        userId: "",
        content: "",
        createdTime: -1
    )
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var editCommentHandler: (() -> Void)?
    
    var beginEditCommentHander: (() -> Void)?
    
    var endEditCommentHandler: (() -> Void)?
    
    func editMessage() {
        
        editCommentHandler?()
    }
    
    func beginEditMessage() {
        
        beginEditCommentHander?()
    }
    
    func endEditMessage() {
        
        endEditCommentHandler?()
    }
    
    func fetchComments() {

        guard
            let article = article else { return }

        PetSocietyFirebaseManager.shared.fetchArticle(withArticleId: article.id) { [weak self] result in

            guard
                let self = self else { return }

            switch result {

            case .success(let article):

                PetSocietyFirebaseManager.shared.setComments(with: self.commentViewModels, comments: article.comments)
                
                self.fetchSenders(withArticle: article)

            case .failure(let error):

                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func leaveComment() {
        
        guard
            let article = article,
            let currentUser = UserFirebaseManager.shared.currentUser
                
        else { return }
        
        comment.articleId = article.id

        comment.userId = currentUser.id

        comment.createdTime = NSDate().timeIntervalSince1970

        PetSocietyFirebaseManager.shared.leaveComment(withArticleId: article.id, comment: comment) { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
        }
        
    }
    
    private func fetchSenders(withArticle article: Article) {

        let userIds = article.comments.map { $0.userId }
        
        UserFirebaseManager.shared.fetchUser(withUserIds: userIds) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                UserFirebaseManager.shared.setUsers(with: self.senderViewModels, users: users)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}

extension PetSocietyCommentViewModel {
    
    func changedContent(with contentText: String) {
        
        comment.content = contentText
    }
}
